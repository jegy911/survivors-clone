class_name WeaponBloodBoomerang
extends WeaponBase

var boomerang_count = 2

func _ready():
	super._ready()
	weapon_name = "Blood Boomerang"
	category = "vampire"
	damage = 30
	cooldown = 1.5
	max_level = 5

func attack():
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return
	enemies.sort_custom(func(a, b):
		return player.global_position.distance_to(a.global_position) < player.global_position.distance_to(b.global_position)
	)
	for i in min(boomerang_count, enemies.size()):
		var b = ObjectPool.get_object("res://projectiles/boomerang.tscn")
		b.global_position = player.global_position
		var dir = (enemies[i].global_position - player.global_position).normalized()
		var final_damage = player.get_total_damage(damage)
		b.init(dir, final_damage, player)
		b.lifesteal = true

func on_upgrade():
	match level:
		2:
			damage = 38
			boomerang_count = 3
		3:
			damage = 46
			cooldown = 1.2
		4:
			damage = 56
			boomerang_count = 4
		5:
			damage = 70
			cooldown = 1.0

func get_description() -> String:
	return "Blood Boomerang Lv" + str(level) + " | x" + str(boomerang_count) + " | " + str(damage) + " hasar"
