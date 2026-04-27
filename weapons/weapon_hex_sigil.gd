class_name WeaponHexSigil
extends WeaponBase

const TEX_HEX := preload("res://assets/projectiles/hex_sigil/hex_sigil_projectile.png")

## Doku dış çember yarıçapı (piksel). 0 = `max(w,h)*0.5*hex_ring_texel_auto_factor`.
@export var hex_outer_radius_texels: float = 0.0
@export var hex_ring_texel_auto_factor: float = 0.52

var radius = 88.0
var slow_factor = 0.30
var slow_duration = 2.0
var hit_cooldowns = {}
const HIT_INTERVAL = 0.85
var _sigil_ring: Sprite2D

func _ready():
	super._ready()
	weapon_name = "Altıgön Mühür"
	tag = "buyu"
	category = "utility"
	damage = 9
	cooldown = 1.2
	call_deferred("_ensure_hex_ring_visual")


func _ensure_hex_ring_visual() -> void:
	if _sigil_ring != null or player == null:
		return
	_sigil_ring = Sprite2D.new()
	_sigil_ring.name = "HexSigilRing"
	_sigil_ring.texture = TEX_HEX
	_sigil_ring.centered = true
	_sigil_ring.z_index = -2
	add_child(_sigil_ring)
	_sync_hex_ring_visual()


func _hex_effective_radius() -> float:
	return radius * float(player.get_area_multiplier())


func _sync_hex_ring_visual() -> void:
	if _sigil_ring == null or player == null or not is_instance_valid(player):
		return
	var eff_r: float = _hex_effective_radius()
	var tex: Texture2D = _sigil_ring.texture
	if tex == null:
		return
	var d: float = maxf(float(tex.get_width()), float(tex.get_height()))
	var outer_texels: float = (
		hex_outer_radius_texels
		if hex_outer_radius_texels > 0.001
		else d * 0.5 * clampf(hex_ring_texel_auto_factor, 0.2, 1.5)
	)
	var s: float = eff_r / maxf(outer_texels, 0.001)
	_sigil_ring.scale = Vector2(s, s)
	_sigil_ring.global_position = player.global_position
	var vfx_a: float = 1.0
	if player.has_method("get_player_vfx_opacity"):
		vfx_a = float(player.get_player_vfx_opacity())
	_sigil_ring.modulate = Color(1.02, 1.05, 1.12, 0.68 * vfx_a)


func _process(delta: float) -> void:
	super._process(delta)
	_sync_hex_ring_visual()

func has_targets_for_attack() -> bool:
	if not hit_cooldowns.is_empty():
		return true
	return _any_enemy_within_distance(radius * player.get_area_multiplier())

func attack():
	var effective_radius = radius * player.get_area_multiplier()
	var enemies = EnemyRegistry.get_enemies()
	for key in hit_cooldowns.keys():
		hit_cooldowns[key] -= get_effective_cooldown()
		if hit_cooldowns[key] <= 0:
			hit_cooldowns.erase(key)
	for enemy in enemies:
		var enemy_id = enemy.get_instance_id()
		if hit_cooldowns.has(enemy_id):
			continue
		if player.global_position.distance_to(enemy.global_position) > effective_radius:
			continue
		var final_damage = player.get_total_damage(damage, enemy)
		enemy.take_damage(final_damage, player)
		EventBus.on_damage_dealt.emit(player, enemy, final_damage)
		if enemy.has_method("apply_slow"):
			enemy.apply_slow(slow_factor, slow_duration)
		hit_cooldowns[enemy_id] = HIT_INTERVAL

func on_upgrade():
	match level:
		2:
			radius = 100.0
			damage = 12
		3:
			cooldown = 1.1
			slow_duration = 2.3
			slow_factor = 0.35
		4:
			radius = 118.0
			damage = 15
		5:
			radius = 135.0
			damage = 18
			cooldown = 0.9
			slow_factor = 0.40

func get_description() -> String:
	return tr("ui.upgrade_ui.stats.loadout_weapons.hex_sigil") % [
		level,
		int(radius * player.get_area_multiplier()),
		damage,
		snappedf(get_effective_cooldown(), 0.01),
	]
