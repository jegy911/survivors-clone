class_name WeaponBindingCircle
extends WeaponBase

const TEX_GLYPH_RING := preload("res://assets/projectiles/binding_circle/glyph.png")

var radius = 138.0
var slow_factor = 0.25
var slow_duration = 2.6
var hit_cooldowns = {}
const HIT_INTERVAL = 0.72
var _ring: Sprite2D

func _ready():
	super._ready()
	weapon_name = "Bağlayıcı Halka"
	tag = "buyu"
	category = "utility"
	damage = 15
	cooldown = 1.0
	call_deferred("_ensure_ring_visual")

func _process(delta: float) -> void:
	super._process(delta)
	_sync_ring_visual()


func _ensure_ring_visual() -> void:
	if _ring != null or player == null:
		return
	_ring = Sprite2D.new()
	_ring.name = "BindingCircleRing"
	_ring.texture = TEX_GLYPH_RING
	_ring.centered = true
	_ring.z_index = -2
	add_child(_ring)
	_sync_ring_visual()


func _binding_effective_radius() -> float:
	if player == null:
		return radius
	return radius * float(player.get_area_multiplier())


func _sync_ring_visual() -> void:
	if _ring == null or player == null:
		return
	var eff_r: float = _binding_effective_radius()
	var tex: Texture2D = _ring.texture
	if tex == null:
		return
	var d: float = maxf(float(tex.get_width()), float(tex.get_height()))
	var outer_texels: float = d * 0.5 * 0.88
	var sc: float = eff_r / maxf(outer_texels, 0.001)
	_ring.scale = Vector2(sc, sc)
	_ring.global_position = player.global_position
	var vfx_a: float = 1.0
	if player.has_method(&"get_player_vfx_opacity"):
		vfx_a = clampf(float(player.get_player_vfx_opacity()), 0.0, 1.0)
	_ring.modulate = Color(1.0, 1.0, 1.08, 0.62 * vfx_a)

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
			damage = 18
			radius = 150.0
		3:
			cooldown = 0.9
			slow_factor = 0.30
		4:
			damage = 22
			radius = 165.0
		5:
			damage = 28
			cooldown = 0.8
			slow_duration = 3.0
			slow_factor = 0.35

func get_description() -> String:
	return tr("ui.upgrade_ui.stats.loadout_weapons.binding_circle") % [
		level,
		int(radius * player.get_area_multiplier()),
		damage,
		snappedf(get_effective_cooldown(), 0.01),
	]
