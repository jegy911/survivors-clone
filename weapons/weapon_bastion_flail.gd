class_name WeaponBastionFlail
extends WeaponBase

var radius = 92.0
## Tank hissi: düşük hasar, yüksek itme (kabaca eski 6 → 18 ≈ 3×).
var knockback: float = 18.0
var hit_cooldowns = {}
const HIT_INTERVAL = 0.75

## 3 sn savurmada tur sayısı — **3’ten büyük** = daha hızlı dönüş (süre aynı).
const FLAIL_SPIN_REVOLUTIONS: float = 3.75
const FLAIL_SPIN_DURATION_SEC: float = 3.0
## Gürz kaybolır / hasar yok.
const FLAIL_PAUSE_DURATION_SEC: float = 9.0
const FLAIL_FULL_CYCLE_SEC: float = FLAIL_SPIN_DURATION_SEC + FLAIL_PAUSE_DURATION_SEC

## Oyuncu `global_position` → hasar çemberi merkezi / `OrbitPivot` konumu (silah lokalinde).
@export var pivot_offset_pixels: Vector2 = Vector2(0, -26)
## Dönen üst düğüm: sahneye `OrbitPivot` (Node2D) koy; **Sprite2D onun altında** — offset/scale/rotation tamamen tasarımda.
@export var orbit_pivot_path: NodePath = ^"OrbitPivot"
## Gürz ucundaki `Area2D` (mermi ile aynı: layer 4, mask 2). Konumunu kalın başa göre sahneye yerleştir.
@export var flail_hitbox_path: NodePath = ^"OrbitPivot/FlailHitbox"
## `true`: savurma sırasında sadece `OrbitPivot.rotation` artar (3 sn’de 3 tur). `false`: rotation’a dokunma (AnimationPlayer vb. sen yönetirsin); yine görünürlük + faz zamanı script’te.
@export var script_drives_orbit_rotation: bool = true

var _phase_clock: float = 0.0
var _was_in_spin_phase: bool = false
var _orbit_pivot: Node2D
var _flail_hitbox: Area2D
var _flail_hit_shape: CollisionShape2D

func _ready():
	super._ready()
	weapon_name = "Kale Gürzü"
	tag = "ezici"
	category = "attack"
	damage = 5
	## Hasar zamanlaması `_process` içinde savurma fazına bağlı; taban `WeaponBase` tetiklemesini kapatır.
	cooldown = 999.0
	_orbit_pivot = get_node_or_null(orbit_pivot_path) as Node2D
	_flail_hitbox = get_node_or_null(flail_hitbox_path) as Area2D
	if _flail_hitbox:
		_flail_hitbox.collision_layer = 4
		_flail_hitbox.collision_mask = 2
		_flail_hitbox.monitorable = false
		_flail_hit_shape = _flail_hitbox.get_node_or_null("CollisionShape2D") as CollisionShape2D


func _process(delta: float) -> void:
	super._process(delta)
	_phase_clock += delta
	while _phase_clock >= FLAIL_FULL_CYCLE_SEC:
		_phase_clock -= FLAIL_FULL_CYCLE_SEC
	var in_spin: bool = _is_in_spin_phase()
	if in_spin and not _was_in_spin_phase:
		if _orbit_pivot and script_drives_orbit_rotation:
			_orbit_pivot.rotation = 0.0
		AudioManager.notify_combat_music_duck_beat()
	_was_in_spin_phase = in_spin
	if in_spin and _orbit_pivot and script_drives_orbit_rotation:
		_orbit_pivot.rotation += (FLAIL_SPIN_REVOLUTIONS * TAU / FLAIL_SPIN_DURATION_SEC) * delta
	_update_flail_visual(delta)
	if in_spin:
		_sync_flail_hitbox_scale()
		_flail_damage_step(delta)
	else:
		_tick_hit_cooldowns_only(delta)


func _is_in_spin_phase() -> bool:
	return fposmod(_phase_clock, FLAIL_FULL_CYCLE_SEC) < FLAIL_SPIN_DURATION_SEC


## Alt sahnede (ör. `Sprite2D` üstü script) savurma fazını okumak için.
func is_flail_spin_active() -> bool:
	return _is_in_spin_phase()


func _pivot_global() -> Vector2:
	if player == null or not is_instance_valid(player):
		return Vector2.ZERO
	return player.global_position + pivot_offset_pixels


func _tick_hit_cooldowns_only(delta: float) -> void:
	for key in hit_cooldowns.keys():
		hit_cooldowns[key] -= delta
		if hit_cooldowns[key] <= 0.0:
			hit_cooldowns.erase(key)


func _update_flail_visual(_delta: float) -> void:
	if _orbit_pivot == null or player == null or not is_instance_valid(player):
		return
	var vfx_a: float = 1.0
	if player.has_method("get_player_vfx_opacity"):
		vfx_a = float(player.get_player_vfx_opacity())
	_orbit_pivot.position = pivot_offset_pixels
	var show_pivot: bool = _is_in_spin_phase() and vfx_a > 0.02
	_orbit_pivot.visible = show_pivot
	if _flail_hitbox:
		_flail_hitbox.monitoring = show_pivot
	if not show_pivot:
		return
	_orbit_pivot.modulate = Color(1.0, 1.0, 1.0, clampf(vfx_a, 0.0, 1.0))


func _sync_flail_hitbox_scale() -> void:
	if _flail_hit_shape == null or player == null or not is_instance_valid(player):
		return
	## `radius` seviye ile büyür; 92 taban — alan çarpanı ile birlikte baş çemberi ölçeklenir.
	const BASE_RADIUS_STAT: float = 92.0
	var m: float = maxf(0.2, player.get_area_multiplier() * (radius / BASE_RADIUS_STAT))
	_flail_hit_shape.scale = Vector2(m, m)


func has_targets_for_attack() -> bool:
	return false


func attack() -> void:
	pass


func _flail_damage_step(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		return
	_tick_hit_cooldowns_only(delta)
	if _flail_hitbox == null or not _flail_hitbox.monitoring:
		return
	var kb_origin: Vector2 = _pivot_global()
	for area in _flail_hitbox.get_overlapping_areas():
		if not area.is_in_group("enemies"):
			continue
		if not area.has_method("take_damage"):
			continue
		var enemy_id: int = area.get_instance_id()
		if hit_cooldowns.has(enemy_id):
			continue
		var final_damage: int = player.get_total_damage(damage, area)
		area.take_damage(final_damage, player)
		EventBus.on_damage_dealt.emit(player, area, final_damage)
		var away: Vector2 = area.global_position - kb_origin
		if away.length_squared() > 0.01:
			area.global_position += away.normalized() * knockback
		hit_cooldowns[enemy_id] = HIT_INTERVAL


func on_upgrade():
	match level:
		2:
			damage = 6
			radius = 100.0
		3:
			knockback = 22.0
		4:
			damage = 8
			radius = 112.0
		5:
			damage = 10
			knockback = 28.0


func get_description() -> String:
	return tr("ui.upgrade_ui.stats.loadout_weapons.bastion_flail") % [
		level,
		int(radius * player.get_area_multiplier()),
		damage,
		int(FLAIL_SPIN_DURATION_SEC),
		int(FLAIL_PAUSE_DURATION_SEC),
	]
