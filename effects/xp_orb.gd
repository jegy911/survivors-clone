extends Area2D

const ACTIVE_LAYER := 8
const ACTIVE_MASK := 1

var xp_value = 10
var player = null
var move_speed = 0.0
var base_attract_radius = 100.0
var collect_radius = 20.0
var _bob_time = 0.0
var _is_moving = false

func _process(delta):
	if not visible:
		return

	var nearest = _get_nearest_player()
	if nearest == null:
		return
	player = nearest

	var attract_radius = base_attract_radius + player.get_magnet_bonus()
	var dist = global_position.distance_to(player.global_position)

	if dist < attract_radius:
		_is_moving = true
		move_speed = min(move_speed + 300.0 * delta, 400.0)
		var dir = (player.global_position - global_position).normalized()
		global_position += dir * move_speed * delta
	else:
		_is_moving = false
		move_speed = 0.0
		# Bob animasyonu sadece beklerken
		_bob_time += delta
		var sprite = get_node_or_null("Sprite2D")
		if sprite:
			sprite.position.y = sin(_bob_time * 3.0) * 3.0

	var all_players = get_tree().get_nodes_in_group("player")
	for p in all_players:
		if global_position.distance_to(p.global_position) < collect_radius:
			p.gain_xp(xp_value)
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
	_bob_time = randf() * TAU
	_is_moving = false
	global_position = pos
	collision_layer = ACTIVE_LAYER
	collision_mask = ACTIVE_MASK
	add_to_group("xp_orbs")
	show()

func vacuum_attract():
	move_speed = 900.0
	base_attract_radius = 99999.0

func reset():
	xp_value = 10
	move_speed = 0.0
	base_attract_radius = 100.0
	player = null
	_bob_time = 0.0
	_is_moving = false
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		sprite.position.y = 0.0
	remove_from_group("xp_orbs")
	collision_layer = 0
	collision_mask = 0
	hide()
