class_name WeaponBastionFlail
extends WeaponBase

var radius = 92.0
var knockback = 6.0
var hit_cooldowns = {}
const HIT_INTERVAL = 0.75

func _ready():
	super._ready()
	weapon_name = "Kale Gürzü"
	tag = "ezici"
	category = "attack"
	damage = 18
	cooldown = 1.4

func attack():
	var effective_radius = radius * player.get_area_multiplier()
	var enemies = EnemyRegistry.get_enemies()
	for key in hit_cooldowns.keys():
		hit_cooldowns[key] -= get_effective_cooldown()
		if hit_cooldowns[key] <= 0:
			hit_cooldowns.erase(key)
	var ppos = player.global_position
	for enemy in enemies:
		var enemy_id = enemy.get_instance_id()
		if hit_cooldowns.has(enemy_id):
			continue
		if ppos.distance_to(enemy.global_position) > effective_radius:
			continue
		var final_damage = player.get_total_damage(damage)
		enemy.take_damage(final_damage, player)
		EventBus.on_damage_dealt.emit(player, enemy, final_damage)
		var kb = (enemy.global_position - ppos).normalized() * knockback
		enemy.global_position += kb
		hit_cooldowns[enemy_id] = HIT_INTERVAL

func on_upgrade():
	match level:
		2:
			damage = 22
			radius = 100.0
		3:
			knockback = 8.0
			cooldown = 1.2
		4:
			damage = 28
			radius = 112.0
		5:
			damage = 35
			knockback = 10.0
			cooldown = 1.0

func get_description() -> String:
	return tr("ui.upgrade_ui.stats.loadout_weapons.bastion_flail") % [
		level,
		int(radius * player.get_area_multiplier()),
		damage,
		snappedf(get_effective_cooldown(), 0.01),
	]
