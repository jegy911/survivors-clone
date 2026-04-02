extends Area2D

var collect_radius = 30.0
var move_speed = 0.0
var base_attract_radius = 80.0

func _ready():
	add_to_group("pickups")
	if get_node_or_null("ColorRect"):
		get_node("ColorRect").color = Color("#00BFFF")
		get_node("ColorRect").size = Vector2(16, 16)
		get_node("ColorRect").position = Vector2(-8, -8)

func _process(delta):
	var players = get_tree().get_nodes_in_group("player")
	for p in players:
		var dist = global_position.distance_to(p.global_position)
		var attract_radius = base_attract_radius + p.get_magnet_bonus()
		if dist < attract_radius:
			move_speed = min(move_speed + 300.0 * delta, 500.0)
			var dir = (p.global_position - global_position).normalized()
			global_position += dir * move_speed * delta
		if dist < collect_radius:
			_on_collected(p)
			return

func _on_collected(player: Node):
	# Tüm düşmanları 10 saniye dondur
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy.has_method("apply_slow"):
			enemy.apply_slow(0.0, 10.0)
	player.show_floating_text(
		"⚙ TIME GEAR! 10sn",
		player.global_position + Vector2(0, -80),
		Color("#00BFFF"), 22
	)
	queue_free()

func init(pos: Vector2):
	global_position = pos
	move_speed = 0.0
	show()
