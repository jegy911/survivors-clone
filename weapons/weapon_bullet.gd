class_name WeaponBullet
extends WeaponBase

var bullet_count = 1
var max_range = 500.0

func _ready():
	super._ready()
	weapon_name = "Mermi"
	tag = "kesici"
	category = "attack"
	damage = 8
	cooldown = 1.4

func has_targets_for_attack() -> bool:
	return _any_enemy_within_distance(max_range * player.get_area_multiplier())

func attack():
	var enemies = EnemyRegistry.get_enemies()
	if enemies.is_empty():
		return
	
	var in_range = []
	for enemy in enemies:
		if player.global_position.distance_to(enemy.global_position) <= max_range:
			in_range.append(enemy)
	
	if in_range.is_empty():
		return
	
	in_range.sort_custom(func(a, b):
		return player.global_position.distance_to(a.global_position) < player.global_position.distance_to(b.global_position)
	)
	
	AudioManager.play_shoot()
	
	var effective_count = bullet_count + get_effective_multi_attack()
	for i in min(effective_count, in_range.size()):
		var bullet = ObjectPool.get_object("res://projectiles/bullet.tscn")
		bullet.global_position = player.global_position
		var dir = (in_range[i].global_position - player.global_position).normalized()
		var final_damage = player.get_total_damage(damage)
		bullet.init(dir, final_damage, false, player)

func on_upgrade():
	match level:
		2:
			bullet_count = 2
			damage = 10
		3:
			cooldown = 1.2
			damage = 12
		4:
			bullet_count = 3
			damage = 15
		5:
			bullet_count = 4
			damage = 18
			cooldown = 1.0

func get_description() -> String:
	return tr("ui.upgrade_ui.stats.loadout_weapons.bullet") % [
		level,
		bullet_count + get_effective_multi_attack(),
		damage,
		int(max_range * player.get_area_multiplier()),
		snappedf(get_effective_cooldown(), 0.01),
	]
