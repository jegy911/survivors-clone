class_name WeaponBloodBoomerang
extends WeaponBase

var boomerang_count = 2

func _ready():
	super._ready()
	weapon_name = "Kan Baltası"
	tag = "kesici"
	category = "vampire"
	damage = 25
	cooldown = 1.8
	max_level = 5

func has_targets_for_attack() -> bool:
	return _any_enemy_within_distance(GameplayConstants.THROW_WEAPON_ENGAGE_RANGE_PX * player.get_area_multiplier())

func attack():
	var enemies = EnemyRegistry.get_enemies()
	if enemies.is_empty():
		return
	enemies.sort_custom(func(a, b):
		return player.global_position.distance_to(a.global_position) < player.global_position.distance_to(b.global_position)
	)
	for i in min(boomerang_count, enemies.size()):
		var atk: Dictionary = player.roll_attack_damage(damage)
		var b = ObjectPool.get_object("res://projectiles/hunter_axe.tscn")
		b.global_position = player.global_position
		var dir = (enemies[i].global_position - player.global_position).normalized()
		b.init(dir, atk.damage, player, true, atk.crit)

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
	return tr("ui.upgrade_ui.stats.loadout_weapons.blood_boomerang") % [
		level,
		boomerang_count,
		damage,
		snappedf(get_effective_cooldown(), 0.01),
	]
