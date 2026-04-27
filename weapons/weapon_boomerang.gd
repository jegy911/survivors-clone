class_name WeaponBoomerang
extends WeaponBase

var boomerang_count = 1

func _ready():
	super._ready()
	weapon_name = "Balta"
	tag = "kesici"
	category = "attack"
	damage = 14
	cooldown = 2.2

func has_targets_for_attack() -> bool:
	return _any_enemy_within_distance(GameplayConstants.THROW_WEAPON_ENGAGE_RANGE_PX * player.get_area_multiplier())

func attack():
	var enemies = EnemyRegistry.get_enemies()
	if enemies.is_empty():
		return
	enemies.sort_custom(func(a, b):
		return player.global_position.distance_to(a.global_position) < player.global_position.distance_to(b.global_position)
	)
	var effective_count = boomerang_count + get_effective_multi_attack()
	for i in min(effective_count, enemies.size()):
		var atk: Dictionary = player.roll_attack_damage(damage)
		var b = ObjectPool.get_object("res://projectiles/hunter_axe.tscn")
		b.global_position = player.global_position
		var dir = (enemies[i].global_position - player.global_position).normalized()
		b.init(dir, atk.damage, player, false, atk.crit)

func on_upgrade():
	match level:
		2: damage = 18; cooldown = 2.0
		3: boomerang_count = 2; damage = 22; cooldown = 2.0
		4: damage = 26; cooldown = 1.8
		5: boomerang_count = 3; damage = 32; cooldown = 1.5

func get_description() -> String:
	return tr("ui.upgrade_ui.stats.loadout_weapons.boomerang") % [
		level,
		boomerang_count + get_effective_multi_attack(),
		damage,
		snappedf(get_effective_cooldown(), 0.01),
	]
