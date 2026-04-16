class_name WeaponGravityAnchor
extends WeaponBase

var radius = 118.0
var pull_strength = 10.0
var hit_cooldowns = {}
const HIT_INTERVAL = 0.95

func _ready():
	super._ready()
	weapon_name = "Çekim Çapası"
	tag = "buyu"
	category = "utility"
	damage = 8
	cooldown = 1.3

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
		if dist > effective_radius or dist < 12.0:
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
			pull_strength = 12.0
			damage = 10
		3:
			radius = 132.0
			cooldown = 1.1
		4:
			pull_strength = 14.0
			damage = 13
		5:
			radius = 148.0
			pull_strength = 16.0
			damage = 16
			cooldown = 0.95

func get_description() -> String:
	return tr("ui.upgrade_ui.stats.loadout_weapons.gravity_anchor") % [
		level,
		int(radius * player.get_area_multiplier()),
		damage,
		snappedf(get_effective_cooldown(), 0.01),
	]
