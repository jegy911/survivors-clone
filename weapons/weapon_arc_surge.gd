class_name WeaponArcSurge
extends WeaponBase

const ARC_SURGE_FX_TEX := preload("res://assets/projectiles/arc_surge/arc_surgeprojectile.png")

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
		var dist: float = player.global_position.distance_to(enemy.global_position)
		if dist > inner and dist < outer:
			return true
	return false

func attack() -> void:
	var par: Node = player.get_parent() if is_instance_valid(player) else null
	if par != null and _donut_has_enemy():
		CombatProjectileFx.spawn_short_lived_projectile_sprite(
			par, player.global_position, player, ARC_SURGE_FX_TEX, Color(1.0, 0.55, 0.45, 0.95), 0.26, 0.18, 0.52
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
		var dist: float = player.global_position.distance_to(enemy.global_position)
		if dist < inner or dist > outer:
			continue
		var final_damage: int = player.get_total_damage(damage, enemy)
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
