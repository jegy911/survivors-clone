class_name WeaponHolyBullet
extends WeaponBase

const HOLY_PROJECTILE_TEX := preload("res://assets/projectiles/holy_bullet/holy_bullet_projectile.png")

var bullet_count = 3

func _ready():
	super._ready()
	weapon_name = "Holy Bullet"
	tag = "buyu"
	category = "attack"
	damage = 25
	cooldown = 1.0
	max_level = 5

func has_targets_for_attack() -> bool:
	const HOLY_ENGAGE := 500.0
	return _any_enemy_within_distance(HOLY_ENGAGE * player.get_area_multiplier())

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
		bullet.init(dir, final_damage, true, player, HOLY_PROJECTILE_TEX)

func on_upgrade():
	match level:
		2:
			damage = 30
		3:
			damage = 35
			bullet_count = 4
			cooldown = 0.9
		4:
			damage = 42
		5:
			damage = 50
			bullet_count = 5
			cooldown = 0.7

func get_description() -> String:
	return tr("ui.upgrade_ui.stats.loadout_weapons.holy_bullet") % [
		level,
		bullet_count,
		damage,
		snappedf(get_effective_cooldown(), 0.01),
	]
