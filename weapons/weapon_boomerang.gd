class_name WeaponBoomerang
extends WeaponBase

var boomerang_scene = preload("res://projectiles/boomerang.tscn")
var boomerang_count = 1

func _ready():
	super._ready()
	weapon_name = "Bumerang"
	category = "attack"
	damage = 18
	cooldown = 2.0

func attack():
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return
	
	enemies.sort_custom(func(a, b):
		return player.global_position.distance_to(a.global_position) < player.global_position.distance_to(b.global_position)
	)
	
	var effective_count = boomerang_count + get_effective_multi_attack()
	for i in min(effective_count, enemies.size()):
		var b = boomerang_scene.instantiate()
		player.get_parent().add_child(b)
		b.global_position = player.global_position
		var dir = (enemies[i].global_position - player.global_position).normalized()
		var final_damage = player.get_total_damage(damage)
		b.init(dir, final_damage, player)

func on_upgrade():
	match level:
		2:
			damage = 22
			cooldown = 1.8
		3:
			boomerang_count = 2
			damage = 26
		4:
			damage = 32
			cooldown = 1.5
		5:
			boomerang_count = 3
			damage = 40
			cooldown = 1.2

func get_description() -> String:
	return "Bumerang Lv" + str(level) + " | x" + str(boomerang_count + get_effective_multi_attack()) + " | " + str(damage) + " hasar"
