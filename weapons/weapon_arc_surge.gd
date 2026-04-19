class_name WeaponArcSurge
extends WeaponBase

## Ark Halkası + Alan Merceği evrimi: daha geniş bant, daha sık vuruş, daha yüksek Might.
var ring_inner: float = 50.0
var ring_outer: float = 178.0
var hit_cooldowns: Dictionary = {}
const HIT_INTERVAL: float = 0.52

func _ready() -> void:
	super._ready()
	weapon_name = "Ark Taşkını"
	tag = "buyu"
	category = "attack"
	damage = 14
	cooldown = 1.0

func attack() -> void:
	var area_m: float = player.get_area_multiplier()
	var inner: float = ring_inner * area_m
	var outer: float = ring_outer * area_m
	var cd_step: float = get_effective_cooldown()
	for k in hit_cooldowns.keys():
		hit_cooldowns[k] -= cd_step
		if hit_cooldowns[k] <= 0.0:
			hit_cooldowns.erase(k)
	var enemies: Array = EnemyRegistry.get_enemies()
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var eid: int = enemy.get_instance_id()
		if hit_cooldowns.has(eid):
			continue
		var dist: float = player.global_position.distance_to(enemy.global_position)
		if dist < inner or dist > outer:
			continue
		var final_damage: int = player.get_total_damage(damage)
		enemy.take_damage(final_damage, player)
		EventBus.on_damage_dealt.emit(player, enemy, final_damage)
		hit_cooldowns[eid] = HIT_INTERVAL

func on_upgrade() -> void:
	match level:
		2:
			damage = 17
			ring_outer = 192.0
		3:
			cooldown = 0.9
			ring_inner = 44.0
		4:
			damage = 21
			ring_outer = 208.0
		5:
			damage = 26
			cooldown = 0.78
			ring_outer = 220.0

func get_description() -> String:
	return tr("ui.upgrade_ui.stats.loadout_weapons.arc_surge") % [
		level,
		int(ring_inner * player.get_area_multiplier()),
		int(ring_outer * player.get_area_multiplier()),
		damage,
		snappedf(get_effective_cooldown(), 0.01),
	]
