class_name WeaponFanBlade
extends WeaponBase

var blade_count = 3
var spread_degrees = 28.0
var fire_range = 128.0
var shard_speed = 240.0
## Saldırı ömrü artık `(fire_range * area) / shard_speed`; bu alan yalnızca okunabilirlik / denge taslağı.
var shard_lifetime = 0.18

func _ready():
	super._ready()
	weapon_name = "Yelpaze Bıçak"
	tag = "kesici"
	category = "attack"
	damage = 6
	cooldown = 1.4

func has_targets_for_attack() -> bool:
	return _any_enemy_within_distance(fire_range * player.get_area_multiplier())

func attack():
	var enemies = EnemyRegistry.get_enemies()
	if enemies.is_empty():
		return
	var eff_reach: float = fire_range * player.get_area_multiplier()
	var nearest = null
	var best = 999999.0
	for enemy in enemies:
		var dist = player.global_position.distance_to(enemy.global_position)
		if dist <= eff_reach and dist < best:
			best = dist
			nearest = enemy
	if nearest == null:
		return
	var base_dir = (nearest.global_position - player.global_position).normalized()
	AudioManager.play_shoot()
	var total_blades = blade_count + get_effective_multi_attack()
	var angles: Array = []
	if total_blades <= 1:
		angles = [0.0]
	else:
		var half = deg_to_rad(spread_degrees)
		var span = half * 2.0
		for i in total_blades:
			angles.append(-half + span * (float(i) / float(total_blades - 1)))
	var tint = Color(0.92, 0.4, 0.1, 1.0)
	## Menzil = `fire_range` × alan; hareket süresi buna göre — sprite ömrü ile hasar mesafesi aynı hizada.
	var shard_life: float = eff_reach / maxf(shard_speed, 1.0)
	for ang in angles:
		var dir = base_dir.rotated(ang)
		var shard = ObjectPool.get_object("res://projectiles/fan_blade_shard.tscn")
		shard.global_position = player.get_directional_attack_spawn(dir)
		shard.init(dir, player.get_total_damage(damage), player, 0, tint, shard_speed, shard_life)

func on_upgrade():
	match level:
		2:
			damage = 8
			spread_degrees = 32.0
			fire_range = 136.0
		3:
			blade_count = 4
			cooldown = 1.2
		4:
			damage = 10
			spread_degrees = 36.0
			fire_range = 144.0
		5:
			blade_count = 5
			damage = 13
			cooldown = 1.0
			shard_speed = 265.0
			shard_lifetime = 0.2

func get_description() -> String:
	return tr("ui.upgrade_ui.stats.loadout_weapons.fan_blade") % [
		level,
		blade_count + get_effective_multi_attack(),
		damage,
		int(fire_range * player.get_area_multiplier()),
		int(spread_degrees),
		snappedf(get_effective_cooldown(), 0.01),
	]
