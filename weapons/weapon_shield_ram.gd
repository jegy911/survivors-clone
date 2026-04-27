class_name WeaponShieldRam
extends WeaponBase

const TEX_RAM := preload("res://assets/projectiles/shield_ram/shield_ram_projectile.png")

## Koni boyunca sprite ölçeği çarpanı (doku boyutuna göre).
@export var ram_visual_length_mult: float = 1.05
@export var ram_visual_fade_sec: float = 0.22

var ram_range = 108.0
var cone_degrees = 72.0

func _ready():
	super._ready()
	weapon_name = "Kalkan Hamlesi"
	tag = "ezici"
	category = "defense"
	damage = 20
	cooldown = 2.2

func has_targets_for_attack() -> bool:
	return _ram_cone_has_target()

func _ram_cone_has_target() -> bool:
	var enemies := EnemyRegistry.get_enemies()
	if enemies.is_empty() or player == null:
		return false
	var nearest: Node2D = null
	var best: float = 999999.0
	var ppos: Vector2 = (player as Node2D).global_position
	for enemy in enemies:
		if not is_instance_valid(enemy) or not enemy is Node2D:
			continue
		var e2: Node2D = enemy as Node2D
		var d: float = ppos.distance_to(e2.global_position)
		if d < best:
			best = d
			nearest = e2
	if nearest == null:
		return false
	var forward: Vector2 = (nearest.global_position - ppos).normalized()
	if forward == Vector2.ZERO:
		forward = Vector2.RIGHT
	var half: float = deg_to_rad(cone_degrees * 0.5)
	var r: float = ram_range * player.get_area_multiplier()
	for enemy in enemies:
		if not is_instance_valid(enemy) or not enemy is Node2D:
			continue
		var e2b: Node2D = enemy as Node2D
		var to_e: Vector2 = e2b.global_position - ppos
		var dist: float = to_e.length()
		if dist > r or dist < 1.0:
			continue
		if forward.angle_to(to_e.normalized()) <= half:
			return true
	return false

func attack():
	var enemies = EnemyRegistry.get_enemies()
	if enemies.is_empty():
		return
	var nearest: Node2D = null
	var best = 999999.0
	var ppos = player.global_position
	for enemy in enemies:
		var d = ppos.distance_to(enemy.global_position)
		if d < best:
			best = d
			nearest = enemy
	if nearest == null:
		return
	var forward = (nearest.global_position - ppos).normalized()
	if forward == Vector2.ZERO:
		forward = Vector2.RIGHT
	var half = deg_to_rad(cone_degrees * 0.5)
	var r = ram_range * player.get_area_multiplier()
	for enemy in enemies:
		var to_e = enemy.global_position - ppos
		var dist = to_e.length()
		if dist > r or dist < 1.0:
			continue
		var dir = to_e.normalized()
		if forward.angle_to(dir) > half:
			continue
		var final_damage = player.get_total_damage(damage, enemy)
		enemy.take_damage(final_damage, player)
		EventBus.on_damage_dealt.emit(player, enemy, final_damage)
		enemy.global_position += dir * 10.0
	_spawn_ram_projectile_fx(ppos, forward, r)

func on_upgrade():
	match level:
		2:
			damage = 25
			ram_range = 118.0
		3:
			cooldown = 1.9
			cone_degrees = 80.0
		4:
			damage = 32
			ram_range = 128.0
		5:
			damage = 40
			cooldown = 1.6
			cone_degrees = 88.0

func _spawn_ram_projectile_fx(ppos: Vector2, forward: Vector2, cone_range: float) -> void:
	if player == null or not is_instance_valid(player):
		return
	var host: Node = player.get_parent()
	if host == null:
		return
	var spr := Sprite2D.new()
	spr.texture = TEX_RAM
	spr.centered = true
	spr.global_position = ppos + forward * (cone_range * 0.38)
	spr.rotation = forward.angle() + PI * 0.5
	var twd: float = maxf(1.0, float(TEX_RAM.get_width()))
	var scale_x: float = maxf(0.12, cone_range * ram_visual_length_mult / twd)
	spr.scale = Vector2(scale_x, scale_x * 0.55)
	var vfx_a: float = 1.0
	if player.has_method("get_player_vfx_opacity"):
		vfx_a = clampf(float(player.get_player_vfx_opacity()), 0.0, 1.0)
	spr.modulate = Color(1.0, 1.0, 1.0, 0.92 * vfx_a)
	spr.z_index = 15
	host.add_child(spr)
	var tw: Tween = spr.create_tween()
	tw.tween_property(spr, "modulate:a", 0.0, ram_visual_fade_sec).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


func get_description() -> String:
	return tr("ui.upgrade_ui.stats.loadout_weapons.shield_ram") % [
		level,
		int(ram_range * player.get_area_multiplier()),
		int(cone_degrees),
		damage,
		snappedf(get_effective_cooldown(), 0.01),
	]
