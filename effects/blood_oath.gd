extends Area2D

const BLOOD_OATH_TEX := preload("res://assets/effects/blood_oath.png")

var attract_speed = 0.0
var attracted = false

func _ready():
	add_to_group("pickups")
	var body = _ensure_visual()
	z_index = 10
	# Nabız efekti
	if body != null:
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(body, "modulate:a", 0.4, 0.5)
		tween.tween_property(body, "modulate:a", 1.0, 0.5)

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


func _ensure_visual() -> CanvasItem:
	var old_rect := get_node_or_null("ColorRect")
	if old_rect != null:
		old_rect.queue_free()
	var spr := get_node_or_null("BodySprite") as Sprite2D
	if spr == null:
		spr = Sprite2D.new()
		spr.name = "BodySprite"
		spr.texture = BLOOD_OATH_TEX
		spr.centered = true
		var dim: float = maxf(float(BLOOD_OATH_TEX.get_width()), 1.0)
		var sc: float = 72.0 / dim
		spr.scale = Vector2(sc, sc)
		add_child(spr)
	return spr
