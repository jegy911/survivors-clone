class_name WeaponHolyBullet
extends WeaponBase

var bullet_count = 3

func _ready():
	super._ready()
	weapon_name = "Holy Bullet"
	tag = "buyu"
	category = "attack"
	damage = 35
	cooldown = 0.8
	max_level = 5

func attack():
	var enemies = EnemyRegistry.get_enemies()
	if enemies.is_empty():
		return
	enemies.sort_custom(func(a, b):
		return player.global_position.distance_to(a.global_position) < player.global_position.distance_to(b.global_position)
	)
	for i in min(bullet_count, enemies.size()):
		var bullet = ObjectPool.get_object("res://projectiles/bullet.tscn")
		bullet.global_position = player.global_position
		var dir = (enemies[i].global_position - player.global_position).normalized()
		var final_damage = player.get_total_damage(damage)
		bullet.init(dir, final_damage, true, player)

func on_upgrade():
	match level:
		2:
			damage = 42
			bullet_count = 4
		3:
			damage = 50
			cooldown = 0.7
		4:
			damage = 60
			bullet_count = 5
		5:
			damage = 75
			cooldown = 0.5

func get_description() -> String:
	return "Holy Bullet Lv" + str(level) + " | x" + str(bullet_count) + " | " + str(damage) + " hasar"
