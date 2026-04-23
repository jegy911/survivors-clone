class_name CenterCataclysmHelper
extends RefCounted
## Ekran ortasında büyüyen tekillik + yarıçap içi anında hasar (`gravity_anchor` / `void_lens`).

const INSTAKILL_DAMAGE: int = 99999


static func screen_center_global(player: Node2D) -> Vector2:
	if player == null or not is_instance_valid(player):
		return Vector2.ZERO
	var vp: Viewport = player.get_viewport()
	if vp == null:
		return player.global_position
	var cam: Camera2D = vp.get_camera_2d() as Camera2D
	if cam != null:
		return cam.get_screen_center_position()
	return player.global_position


static func apply_instakill_in_radius(center_global: Vector2, radius_px: float, attacker: Node) -> void:
	for enemy in EnemyRegistry.get_enemies():
		if not is_instance_valid(enemy):
			continue
		if not enemy is Node2D:
			continue
		var n: Node2D = enemy as Node2D
		if center_global.distance_to(n.global_position) > radius_px:
			continue
		if not enemy.has_method(&"take_damage"):
			continue
		enemy.take_damage(INSTAKILL_DAMAGE, attacker)
		EventBus.on_damage_dealt.emit(attacker, enemy, INSTAKILL_DAMAGE)


## `weapon` üzerinde `_on_cataclysm_pulse_finished()` çağrılır (timer sıfırlama).
static func spawn_grow_pulse(
	weapon: Node,
	player: Node2D,
	texture: Texture2D,
	center_global: Vector2,
	radius_px: float,
	scale_from: float,
	scale_to: float,
	grow_sec: float,
) -> void:
	if texture == null or player == null or not is_instance_valid(player):
		if is_instance_valid(weapon) and weapon.has_method(&"_on_cataclysm_pulse_finished"):
			weapon._on_cataclysm_pulse_finished()
		return
	var host: Node = player.get_parent()
	if host == null:
		if is_instance_valid(weapon) and weapon.has_method(&"_on_cataclysm_pulse_finished"):
			weapon._on_cataclysm_pulse_finished()
		return
	var spr := Sprite2D.new()
	spr.centered = true
	spr.texture = texture
	spr.global_position = center_global
	spr.scale = Vector2(scale_from, scale_from)
	spr.z_index = 120
	var vfx_a: float = 1.0
	if player.has_method(&"get_player_vfx_opacity"):
		vfx_a = clampf(float(player.get_player_vfx_opacity()), 0.0, 1.0)
	spr.modulate = Color(1.0, 1.0, 1.0, vfx_a)
	host.add_child(spr)
	var tw: Tween = spr.create_tween()
	tw.tween_property(spr, "scale", Vector2(scale_to, scale_to), maxf(0.05, grow_sec)).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tw.finished.connect(func() -> void:
		if is_instance_valid(spr):
			spr.queue_free()
		CenterCataclysmHelper.apply_instakill_in_radius(center_global, radius_px, player)
		if is_instance_valid(weapon) and weapon.has_method(&"_on_cataclysm_pulse_finished"):
			weapon._on_cataclysm_pulse_finished()
	)
