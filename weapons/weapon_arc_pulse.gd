class_name WeaponArcPulse
extends WeaponBase

const ARC_PULSE_FX_TEX := preload("res://assets/projectiles/arc_pulse/arc_pulseprojectile.png")

## Halka bant (donut) içinde periyodik büyü hasarı — yavaşlatma yok; alan odaklı mage ritmi.
var ring_inner: float = 70.0
var ring_outer: float = 128.0
var hit_cooldowns: Dictionary = {}
const HIT_INTERVAL: float = 0.78

func _ready() -> void:
	super._ready()
	weapon_name = "Ark Halkası"
	tag = "buyu"
	category = "attack"
	damage = 10
	cooldown = 1.18

func has_targets_for_attack() -> bool:
	if not hit_cooldowns.is_empty():
		return true
	return _donut_has_enemy()

func _donut_has_enemy() -> bool:
	var area_m: float = player.get_area_multiplier()
	var inner: float = ring_inner * area_m
	var outer: float = ring_outer * area_m
	for enemy in EnemyRegistry.get_enemies():
		if not is_instance_valid(enemy) or not enemy is Node2D:
			continue
		var d: float = player.global_position.distance_to(enemy.global_position)
		if d > inner and d < outer:
			return true
	return false

func attack() -> void:
	var par: Node = player.get_parent() if is_instance_valid(player) else null
	if par != null and _donut_has_enemy():
		CombatProjectileFx.spawn_short_lived_projectile_sprite(
			par, player.global_position, player, ARC_PULSE_FX_TEX, Color(0.78, 0.68, 1.0, 0.92)
		)
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
		var d: float = player.global_position.distance_to(enemy.global_position)
		if d < inner or d > outer:
			continue
		var final_damage: int = player.get_total_damage(damage)
		enemy.take_damage(final_damage, player)
		EventBus.on_damage_dealt.emit(player, enemy, final_damage)
		hit_cooldowns[eid] = HIT_INTERVAL

func on_upgrade() -> void:
	match level:
		2:
			ring_outer = 142.0
			damage = 12
		3:
			ring_inner = 62.0
			cooldown = 1.08
		4:
			damage = 15
			ring_outer = 158.0
		5:
			damage = 18
			cooldown = 0.92
			ring_inner = 54.0

func get_description() -> String:
	return tr("ui.upgrade_ui.stats.loadout_weapons.arc_pulse") % [
		level,
		int(ring_inner * player.get_area_multiplier()),
		int(ring_outer * player.get_area_multiplier()),
		damage,
		snappedf(get_effective_cooldown(), 0.01),
	]
