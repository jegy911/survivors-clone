extends RefCounted
class_name CombatProjectileFx

const LIGHTNING_HIT_FX := preload("res://effects/lightning_hit_fx.tscn")
const TEX_CHAIN := preload("res://assets/projectiles/chain/chain.png")
## `true`: zincir halkaları dokunun **genişliği** boyunca (+X yönü); `false`: **yükseklik** boyunca (dikey PNG için).
const CHAIN_TEX_LINKS_ALONG_WIDTH := true
## Doku yüksekliğine göre kalınlık çarpanı (genişlik `mesafe` ile otomatik uzar).
const CHAIN_SEGMENT_THICKNESS := 0.22
## Renk çarpanı (1 = değişmez); >1 biraz daha “dolu” görünür.
const CHAIN_MODULATE_RGB_BOOST := 1.12
## Solma: daha uzun süre tam opak kalır.
const CHAIN_FADE_DURATION_SEC := 0.42


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


## İki nokta arasında `chain.png`: ortada, yönü segmente göre döner, X ölçeği mesafeyi kaplar.
static func spawn_chain_segment(
	parent: Node,
	from_global: Vector2,
	to_global: Vector2,
	player: Node2D,
	tint: Color
) -> void:
	var seg: Vector2 = to_global - from_global
	var dist: float = seg.length()
	if dist < 3.0:
		return
	var spr := Sprite2D.new()
	spr.texture = TEX_CHAIN
	spr.centered = true
	spr.z_index = 120
	spr.z_as_relative = false
	var vfx_a := 1.0
	if player and player.has_method("get_player_vfx_opacity"):
		vfx_a = player.get_player_vfx_opacity()
	var a0: float = minf(1.0, tint.a * vfx_a)
	spr.modulate = Color(
		minf(1.0, tint.r * CHAIN_MODULATE_RGB_BOOST),
		minf(1.0, tint.g * CHAIN_MODULATE_RGB_BOOST),
		minf(1.0, tint.b * CHAIN_MODULATE_RGB_BOOST),
		a0
	)
	parent.add_child(spr)
	spr.global_position = from_global.lerp(to_global, 0.5)
	if CHAIN_TEX_LINKS_ALONG_WIDTH:
		var w: float = maxf(float(TEX_CHAIN.get_width()), 1.0)
		spr.rotation = seg.angle()
		spr.scale = Vector2(dist / w, CHAIN_SEGMENT_THICKNESS)
	else:
		var h: float = maxf(float(TEX_CHAIN.get_height()), 1.0)
		spr.rotation = seg.angle() - PI * 0.5
		spr.scale = Vector2(CHAIN_SEGMENT_THICKNESS, dist / h)
	var tw := spr.create_tween()
	tw.tween_property(spr, "modulate:a", 0.0, CHAIN_FADE_DURATION_SEC)
	tw.tween_callback(spr.queue_free)
