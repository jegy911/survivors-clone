extends Area2D

var attract_speed = 0.0
var attracted = false

func _ready():
	add_to_group("pickups")
	var body = get_node_or_null("ColorRect")
	if body:
		body.color = Color("#8B0000")
		body.size = Vector2(14, 14)
		body.position = Vector2(-7, -7)
	z_index = 10
	# Nabız efekti
	if get_node_or_null("ColorRect"):
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property($ColorRect, "modulate:a", 0.4, 0.5)
		tween.tween_property($ColorRect, "modulate:a", 1.0, 0.5)

func _process(delta):
	if not visible:
		return
	var nearest = _get_nearest_player()
	if nearest == null:
		return
	var dist = global_position.distance_to(nearest.global_position)
	var effective_range = 80.0 + nearest.get_magnet_bonus()
	if dist < effective_range:
		attracted = true
	if attracted:
		attract_speed = min(attract_speed + 400 * delta, 500)
		var dir = (nearest.global_position - global_position).normalized()
		global_position += dir * attract_speed * delta
	var all_players = get_tree().get_nodes_in_group("player")
	for p in all_players:
		if global_position.distance_to(p.global_position) < 15:
			_on_collected(p)
			queue_free()
			return

func _on_collected(collector: Node):
	if SaveManager.game_mode != "local_coop":
		# Solo modda altına dönüşür
		collector.collect_gold(25)
		collector.show_floating_text("💰 +25", collector.global_position + Vector2(0, -60), Color("#FFD700"), 16)
		return
	# Co-op modda: diğer oyuncu yakın mı kontrol et
	var players = get_tree().get_nodes_in_group("player")
	var other = null
	for p in players:
		if p != collector:
			other = p
			break
	if other == null:
		collector.collect_gold(25)
		return
	var dist = collector.global_position.distance_to(other.global_position)
	if dist <= 120.0:
		# Her iki oyuncuya da Blood Oath ver
		for p in players:
			p.activate_blood_oath()
		collector.show_floating_text(
			"🩸 KAN YEMİNİ!",
			collector.global_position + Vector2(0, -90),
			Color("#FF0000"), 24
		)
	else:
		# Diğer oyuncu uzaktaysa sadece altın
		collector.collect_gold(25)
		collector.show_floating_text(
			"🩸 Yakın ol!",
			collector.global_position + Vector2(0, -60),
			Color("#8B0000"), 16
		)

func _get_nearest_player() -> Node:
	var players = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return null
	var nearest = players[0]
	var nearest_dist = global_position.distance_to(nearest.global_position)
	for p in players:
		var dist = global_position.distance_to(p.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = p
	return nearest

func init(pos: Vector2):
	attracted = false
	attract_speed = 0.0
	global_position = pos
	show()
