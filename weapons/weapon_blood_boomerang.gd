class_name WeaponBloodBoomerang
extends WeaponBase

var boomerang_count = 2

func _ready():
	super._ready()
	weapon_name = "Blood Boomerang"
	tag = "kesici"
	category = "vampire"
	damage = 25
	cooldown = 1.8
	max_level = 5

func attack():
	var enemies = EnemyRegistry.get_enemies()
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
			damage = 30
		3:
			damage = 36
			boomerang_count = 3
			cooldown = 1.6
		4:
			damage = 44
		5:
			damage = 55
			boomerang_count = 4
			cooldown = 1.3

func get_description() -> String:
	return "Blood Boomerang Lv" + str(level) + " | x" + str(boomerang_count) + " | " + str(damage) + " hasar"
