class_name WeaponVeilDaggers
extends WeaponBase

const VEIL_DAGGER_TEXTURE := preload("res://assets/projectiles/dagger/veil_shard.png")

var dagger_count := 3
var max_range := 520.0
var proj_pierce := 1

func _ready() -> void:
	super._ready()
	weapon_name = "Peçe Hançerleri"
	tag = "kesici"
	category = "attack"
	damage = 6
	cooldown = 1.18

func has_targets_for_attack() -> bool:
	return _any_enemy_within_distance(max_range * player.get_area_multiplier())

func attack() -> void:
	var enemies = EnemyRegistry.get_enemies()
	if enemies.is_empty():
		return
	var in_range: Array = []
	for enemy in enemies:
		if player.global_position.distance_to(enemy.global_position) <= max_range:
			in_range.append(enemy)
	if in_range.is_empty():
		return
	in_range.sort_custom(func(a, b):
		return player.global_position.distance_to(a.global_position) < player.global_position.distance_to(b.global_position)
	)
	AudioManager.play_shoot()
	var effective_count: int = dagger_count + get_effective_multi_attack()
	for i in min(effective_count, in_range.size()):
		var atk: Dictionary = player.roll_attack_damage(damage)
		var proj: Node = ObjectPool.get_object("res://projectiles/dagger.tscn")
		proj.pierce_count = proj_pierce
		proj.global_position = player.global_position
		var dir: Vector2 = (in_range[i].global_position - player.global_position).normalized()
		proj.init(dir, atk.damage, false, player, VEIL_DAGGER_TEXTURE, atk.crit)

func on_upgrade() -> void:
	match level:
		2:
			dagger_count = 4
			damage = 7
		3:
			cooldown = 1.02
			damage = 8
		4:
			dagger_count = 5
			damage = 9
		5:
			damage = 10
			cooldown = 0.9
			proj_pierce = 2

func get_description() -> String:
	return tr("ui.upgrade_ui.stats.loadout_weapons.veil_daggers") % [
		level,
		dagger_count + get_effective_multi_attack(),
		damage,
		proj_pierce,
		int(max_range * player.get_area_multiplier()),
		snappedf(get_effective_cooldown(), 0.01),
	]
