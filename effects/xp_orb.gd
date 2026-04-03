extends Area2D

var xp_value = 10
var player = null
var move_speed = 0.0
var base_attract_radius = 100.0
var collect_radius = 20.0

func _process(delta):
	if not visible:
		return
	
	# En yakın oyuncuyu bul ve ona çekil
	var nearest = _get_nearest_player()
	if nearest == null:
		return
	player = nearest
	
	var attract_radius = base_attract_radius + player.get_magnet_bonus()
	var dist = global_position.distance_to(player.global_position)
	
	if dist < attract_radius:
		move_speed = min(move_speed + 300.0 * delta, 400.0)
		var dir = (player.global_position - global_position).normalized()
		global_position += dir * move_speed * delta
	else:
		move_speed = 0.0
	
	# Herhangi bir oyuncu collect_radius'a girerse toplar
	var all_players = get_tree().get_nodes_in_group("player")
	for p in all_players:
		if global_position.distance_to(p.global_position) < collect_radius:
			p.gain_xp(xp_value)
			# Diğer oyuncular %50 alır
			for other in all_players:
				if other != p:
					other.gain_xp(int(xp_value * 0.5))
			ObjectPool.return_object(self)
			return

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

func init(value: int, pos: Vector2):
	xp_value = max(1, value)
	move_speed = 0.0
	player = null
	global_position = pos
	if get_node_or_null("ColorRect"):
		get_node("ColorRect").name = "Body"
	add_to_group("xp_orbs")
	show()
	# Bob animasyonu
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(self, "position", position + Vector2(0, -4), 0.6).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position", position, 0.6).set_trans(Tween.TRANS_SINE)

func vacuum_attract():
	move_speed = 900.0
	base_attract_radius = 99999.0

func reset():
	xp_value = 10
	move_speed = 0.0
	base_attract_radius = 100.0
	player = null
	remove_from_group("xp_orbs")
	hide()
