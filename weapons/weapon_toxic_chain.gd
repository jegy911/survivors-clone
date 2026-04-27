class_name WeaponToxicChain
extends WeaponBase

var chain_count = 4
var chain_range = 250.0

func _ready():
	super._ready()
	weapon_name = "Toxic Chain"
	tag = "patlayici"
	category = "attack"
	damage = 18
	cooldown = 1.6
	max_level = 5

func has_targets_for_attack() -> bool:
	return _any_enemy_within_distance(chain_range * player.get_area_multiplier())

func attack():
	var enemies = EnemyRegistry.get_enemies()
	if enemies.is_empty():
		return
	var eff_r: float = chain_range * player.get_area_multiplier()
	enemies.sort_custom(func(a, b): return player.global_position.distance_to(a.global_position) < player.global_position.distance_to(b.global_position))
	var first_enemy = enemies[0]
	if player.global_position.distance_to(first_enemy.global_position) > eff_r:
		return
	var final_damage = player.get_total_damage(damage, first_enemy)
	first_enemy.take_damage(final_damage, player)
	first_enemy.apply_poison(8, 4.0)
	_spawn_lightning(first_enemy.global_position)
	var hit_enemies = [first_enemy]
	var current = first_enemy
	for i in chain_count - 1:
		var next = _find_next(current, hit_enemies)
		if next == null:
			break
		next.take_damage(final_damage, player)
		next.apply_poison(8, 4.0)
		_spawn_lightning(next.global_position)
		hit_enemies.append(next)
		current = next

func _find_next(current: Node, hit: Array):
	var enemies = EnemyRegistry.get_enemies()
	var nearest = null
	var nearest_dist = chain_range
	for enemy in enemies:
		if enemy in hit:
			continue
		var dist = current.global_position.distance_to(enemy.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = enemy
	return nearest

func _spawn_lightning(pos: Vector2):
	CombatProjectileFx.spawn_lightning_style_flash(player.get_parent(), pos, player, &"toxic")

func on_upgrade():
	match level:
		2:
			damage = 22
		3:
			damage = 28
			chain_count = 5
			chain_range = 300.0
			cooldown = 1.5
		4:
			damage = 34
		5:
			damage = 42
			chain_count = 6
			chain_range = 350.0
			cooldown = 1.3

func get_description() -> String:
	return tr("ui.upgrade_ui.stats.loadout_weapons.toxic_chain") % [
		level,
		chain_count,
		damage,
		int(chain_range * player.get_area_multiplier()),
		snappedf(get_effective_cooldown(), 0.01),
	]
