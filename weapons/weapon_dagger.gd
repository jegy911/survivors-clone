class_name WeaponDagger
extends WeaponBase

var dagger_count := 2
var max_range := 500.0

func _ready() -> void:
	super._ready()
	weapon_name = "Hançer"
	tag = "kesici"
	category = "attack"
	damage = 5
	cooldown = 1.28

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
		var proj: Node = ObjectPool.get_object("res://projectiles/dagger.tscn")
		proj.pierce_count = 0
		proj.global_position = player.global_position
		var dir: Vector2 = (in_range[i].global_position - player.global_position).normalized()
		var final_damage: int = player.get_total_damage(damage)
		proj.init(dir, final_damage, false, player)

func on_upgrade() -> void:
	match level:
		2:
			dagger_count = 3
			damage = 6
		3:
			cooldown = 1.12
			damage = 7
		4:
			dagger_count = 4
			damage = 8
		5:
			dagger_count = 5
			damage = 9
			cooldown = 0.95

func get_description() -> String:
	return tr("ui.upgrade_ui.stats.loadout_weapons.dagger") % [
		level,
		dagger_count + get_effective_multi_attack(),
		damage,
		int(max_range * player.get_area_multiplier()),
		snappedf(get_effective_cooldown(), 0.01),
	]
