class_name WeaponVoidLens
extends WeaponBase

var radius = 158.0
var pull_strength = 14.0
var hit_cooldowns = {}
const HIT_INTERVAL = 0.78

func _ready():
	super._ready()
	weapon_name = "Uçurum Merceği"
	tag = "buyu"
	category = "utility"
	damage = 12
	cooldown = 1.1

func has_targets_for_attack() -> bool:
	if not hit_cooldowns.is_empty():
		return true
	var R: float = radius * player.get_area_multiplier()
	var inner: float = 10.0
	var ppos: Vector2 = player.global_position
	for e in EnemyRegistry.get_enemies():
		if is_instance_valid(e) and e is Node2D:
			var d: float = ppos.distance_to((e as Node2D).global_position)
			if d > inner and d <= R:
				return true
	return false

func attack():
	var effective_radius = radius * player.get_area_multiplier()
	var enemies = EnemyRegistry.get_enemies()
	for key in hit_cooldowns.keys():
		hit_cooldowns[key] -= get_effective_cooldown()
		if hit_cooldowns[key] <= 0:
			hit_cooldowns.erase(key)
	var ppos = player.global_position
	for enemy in enemies:
		var dist = ppos.distance_to(enemy.global_position)
		if dist > effective_radius or dist < 10.0:
			continue
		var dir = (ppos - enemy.global_position).normalized()
		enemy.global_position += dir * pull_strength
		var enemy_id = enemy.get_instance_id()
		if hit_cooldowns.has(enemy_id):
			continue
		var final_damage = player.get_total_damage(damage)
		enemy.take_damage(final_damage, player)
		EventBus.on_damage_dealt.emit(player, enemy, final_damage)
		hit_cooldowns[enemy_id] = HIT_INTERVAL

func on_upgrade():
	match level:
		2:
			damage = 15
			pull_strength = 16.0
		3:
			radius = 172.0
			cooldown = 0.9
		4:
			damage = 18
			pull_strength = 18.0
		5:
			damage = 23
			radius = 188.0
			pull_strength = 20.0
			cooldown = 0.8

func get_description() -> String:
	return tr("ui.upgrade_ui.stats.loadout_weapons.void_lens") % [
		level,
		int(radius * player.get_area_multiplier()),
		damage,
		snappedf(get_effective_cooldown(), 0.01),
	]
