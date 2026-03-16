class_name WeaponIceBall
extends WeaponBase

var ball_count = 1

func _ready():
	super._ready()
	weapon_name = "Buz Topu"
	tag = "buyu"
	category = "defense"
	damage = 22
	cooldown = 2.0

func attack():
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return
	enemies.sort_custom(func(a, b):
		return player.global_position.distance_to(a.global_position) < player.global_position.distance_to(b.global_position)
	)
	for i in min(ball_count, enemies.size()):
		var ball = ObjectPool.get_object("res://projectiles/ice_ball.tscn")
		ball.global_position = player.global_position
		var dir = (enemies[i].global_position - player.global_position).normalized()
		var final_damage = player.get_total_damage(damage)
		ball.init(dir, final_damage, player)

func on_upgrade():
	match level:
		2: damage = 30; cooldown = 1.8
		3: ball_count = 2; damage = 38
		4: damage = 48; cooldown = 1.5
		5: ball_count = 3; damage = 60; cooldown = 1.2

func get_description() -> String:
	return "Buz Topu Lv" + str(level) + " | x" + str(ball_count) + " | " + str(damage) + " hasar | yavaşlatır"
