extends Area2D

var xp_value = 10
var player = null
var move_speed = 0.0
var base_attract_radius = 100.0
var collect_radius = 20.0

func _process(delta):
	if not visible:
		return
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		return
	
	var attract_radius = base_attract_radius + player.get_magnet_bonus()
	var dist = global_position.distance_to(player.global_position)
	
	if dist < attract_radius:
		move_speed = min(move_speed + 300.0 * delta, 400.0)
		var dir = (player.global_position - global_position).normalized()
		global_position += dir * move_speed * delta
	else:
		move_speed = 0.0
	
	if dist < collect_radius:
		player.gain_xp(xp_value)
		ObjectPool.return_object(self)

func init(value: int, pos: Vector2):
	xp_value = max(1, value)
	move_speed = 0.0
	player = null
	global_position = pos
	# Görsel hazırlık — ileride Sprite2D ile değiştirilecek
	if get_node_or_null("ColorRect"):
		get_node("ColorRect").name = "Body"
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
	remove_from_group("xp_orbs")
	hide()
