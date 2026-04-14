extends RefCounted
class_name CombatProjectileFx

const LIGHTNING_HIT_FX := preload("res://effects/lightning_hit_fx.tscn")
const TEX_CHAIN := preload("res://assets/projectiles/chain/chain.png")


static func spawn_lightning_style_flash(
	parent: Node,
	global_pos: Vector2,
	player: Node2D,
	style: StringName = &"lightning"
) -> void:
	var fx: Node = LIGHTNING_HIT_FX.instantiate()
	parent.add_child(fx)
	fx.global_position = global_pos
	if fx.has_method("run"):
		fx.call("run", player, style)


## İki nokta arasında dokulu zincir çizgisi (kısa ömürlü).
static func spawn_chain_segment(
	parent: Node,
	from_global: Vector2,
	to_global: Vector2,
	player: Node2D,
	tint: Color
) -> void:
	var line := Line2D.new()
	line.texture = TEX_CHAIN
	## TILE için UV tekrarı; aksi halde doku tek renk / boş görünebilir.
	line.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	line.texture_mode = Line2D.LINE_TEXTURE_TILE
	line.width = 16.0
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	## Doku renkleri çarpılır; koyu çizgi yerine zincir PNG’si görünsün.
	line.default_color = Color.WHITE
	var vfx_a := 1.0
	if player and player.has_method("get_player_vfx_opacity"):
		vfx_a = player.get_player_vfx_opacity()
	line.modulate = Color(tint.r, tint.g, tint.b, tint.a * vfx_a)
	line.z_index = 120
	line.z_as_relative = false
	parent.add_child(line)
	line.global_position = from_global
	line.add_point(Vector2.ZERO)
	line.add_point(to_global - from_global)
	var tw := line.create_tween()
	tw.tween_property(line, "modulate:a", 0.0, 0.24)
	tw.tween_callback(line.queue_free)
