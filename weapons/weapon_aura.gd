class_name WeaponAura
extends WeaponBase

const TEX_AURA := preload("res://assets/projectiles/aura/aura.png")

## Doku üzerinde merkez → **dış hasar çemberi** uzaklığı (piksel). 0 = aşağıdaki faktörle otomatik (doku kutusu × faktör).
## Aura PNG’si büyük şeffaf kenarlıysa, `aura_outer_radius_texels` ile elle piksel vermek en doğrusu.
@export var aura_outer_radius_texels: float = 0.0
## `aura_outer_radius_texels == 0` iken: dış çember yarıçapı ≈ `max(w,h) * 0.5 * bu faktör`. **<1** = halka büyür (hasar kenarına yaklaşır); meta alan çarpanı zaten `get_area_multiplier()` ile hem hasar hem görselde aynı.
@export var aura_outer_texel_auto_factor: float = 0.88

var radius = 80.0
var slow_factor = 0.2
var hit_cooldowns = {}
const HIT_INTERVAL = 1.0
var _ring: Sprite2D

func _ready():
	super._ready()
	weapon_name = "Aura"
	tag = "patlayici"
	category = "attack"
	damage = 10
	cooldown = 1.2
	call_deferred("_ensure_ring_visual")

func has_targets_for_attack() -> bool:
	if not hit_cooldowns.is_empty():
		return true
	return _any_enemy_within_distance(_aura_effective_radius())

func _ensure_ring_visual() -> void:
	if _ring != null or player == null:
		return
	_ring = Sprite2D.new()
	_ring.name = "AuraWeaponRing"
	_ring.texture = TEX_AURA
	_ring.centered = true
	_ring.z_index = -2
	# Silah düğümünün çocuğu olmalı: level-up önizlemesi / `queue_free` ile halka da temizlenir.
	add_child(_ring)
	_sync_ring_visual()

func _aura_effective_radius() -> float:
	return radius * float(player.get_area_multiplier())


func _sync_ring_visual() -> void:
	if _ring == null or player == null:
		return
	var eff_r: float = _aura_effective_radius()
	var tex := _ring.texture
	if tex == null:
		return
	var d: float = maxf(float(tex.get_width()), float(tex.get_height()))
	var outer_texels: float = (
		aura_outer_radius_texels
		if aura_outer_radius_texels > 0.001
		else d * 0.5 * clampf(aura_outer_texel_auto_factor, 0.2, 1.5)
	)
	var s: float = eff_r / maxf(outer_texels, 0.001)
	_ring.scale = Vector2(s, s)
	_ring.global_position = player.global_position
	var vfx_a: float = 1.0
	if player.has_method("get_player_vfx_opacity"):
		vfx_a = float(player.get_player_vfx_opacity())
	# Daha okunaklı halka (önceki ~0.42 çok soluktu)
	_ring.modulate = Color(1.05, 1.02, 1.12, 0.72 * vfx_a)

func _process(delta: float) -> void:
	super._process(delta)
	_sync_ring_visual()

func attack():
	var effective_radius: float = _aura_effective_radius()
	var enemies = EnemyRegistry.get_enemies()
	# Hit cooldown'ları temizle
	for key in hit_cooldowns.keys():
		hit_cooldowns[key] -= get_effective_cooldown()
		if hit_cooldowns[key] <= 0:
			hit_cooldowns.erase(key)
	for enemy in enemies:
		var enemy_id = enemy.get_instance_id()
		if hit_cooldowns.has(enemy_id):
			continue
		if player.global_position.distance_to(enemy.global_position) <= effective_radius:
			var final_damage = player.get_total_damage(damage, enemy)
			enemy.take_damage(final_damage, player)
			EventBus.on_damage_dealt.emit(player, enemy, final_damage)
			if enemy.has_method("apply_slow"):
				enemy.apply_slow(slow_factor, 1.5)
			hit_cooldowns[enemy_id] = HIT_INTERVAL
			

func on_upgrade():
	match level:
		2:
			radius = 100.0
			damage = 14
		3:
			cooldown = 1.0
			damage = 18
			slow_factor = 0.25
		4:
			radius = 120.0
			damage = 22
		5:
			radius = 140.0
			damage = 28
			cooldown = 0.8
			slow_factor = 0.3

func get_description() -> String:
	return tr("ui.upgrade_ui.stats.loadout_weapons.aura") % [
		level,
		int(radius * player.get_area_multiplier()),
		damage,
		snappedf(get_effective_cooldown(), 0.01),
	]
