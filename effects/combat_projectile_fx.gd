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


## Silah dokusu: oyuncu etrafında kısa süre büyüyüp solan bir `Sprite2D` (ör. Ark Halkası nabız görseli).
static func spawn_short_lived_projectile_sprite(
	parent: Node,
	global_pos: Vector2,
	player: Node2D,
	tex: Texture2D,
	tint: Color,
	duration: float = 0.24,
	start_scale: float = 0.16,
	end_scale: float = 0.44
) -> void:
	if parent == null or tex == null:
		return
	var s := Sprite2D.new()
	s.texture = tex
	s.centered = true
	s.global_position = global_pos
	s.scale = Vector2(start_scale, start_scale)
	s.z_index = 90
	s.z_as_relative = false
	var vfx_a := 1.0
	if player and player.has_method("get_player_vfx_opacity"):
		vfx_a = float(player.get_player_vfx_opacity())
	s.modulate = Color(tint.r, tint.g, tint.b, minf(1.0, tint.a * vfx_a))
	parent.add_child(s)
	var tw := s.create_tween()
	tw.set_parallel(true)
	tw.tween_property(s, "scale", Vector2(end_scale, end_scale), duration * 0.88)
	tw.tween_property(s, "modulate:a", 0.0, duration)
	tw.chain().tween_callback(s.queue_free)


## Small pixel-style burst (dark rim + bright chips) for readable hit feedback.
static func spawn_hit_sparks(
	parent: Node,
	global_pos: Vector2,
	player: Node2D,
	tint: Color,
	count: int = 9,
	spread: float = 40.0,
	lifetime: float = 0.2
) -> void:
	if parent == null:
		return
	var vfx_a := 1.0
	if player and player.has_method("get_player_vfx_opacity"):
		vfx_a = player.get_player_vfx_opacity()
	var a0: float = minf(1.0, tint.a * vfx_a)
	var n: int = max(4, count)
	for i in n:
		var sz: float = randf_range(3.0, 6.0)
		var p0: Vector2 = global_pos + Vector2(randf_range(-2.0, 2.0), randf_range(-2.0, 2.0))
		var rim := ColorRect.new()
		rim.size = Vector2(sz + 2.0, sz + 2.0)
		rim.color = Color(0.04, 0.04, 0.06, minf(0.92, a0))
		parent.add_child(rim)
		rim.global_position = p0
		var core := ColorRect.new()
		core.size = Vector2(sz, sz)
		core.color = Color(
			minf(1.0, tint.r * 1.08),
			minf(1.0, tint.g * 1.08),
			minf(1.0, tint.b * 1.08),
			a0
		)
		parent.add_child(core)
		core.global_position = p0 + Vector2(1.0, 1.0)
		var ang: float = TAU * float(i) / float(n) + randf_range(-0.35, 0.35)
		var dst: Vector2 = global_pos + Vector2(cos(ang), sin(ang)) * randf_range(spread * 0.35, spread)
		var lt: float = randf_range(0.11, lifetime)
		var tw := core.create_tween()
		tw.set_parallel(true)
		tw.tween_property(core, "global_position", dst, lt)
		tw.tween_property(core, "modulate:a", 0.0, lt)
		tw.chain().tween_callback(core.queue_free)
		var tw2 := rim.create_tween()
		tw2.set_parallel(true)
		tw2.tween_property(rim, "global_position", dst - Vector2(1.0, 1.0), lt)
		tw2.tween_property(rim, "modulate:a", 0.0, lt * 0.95)
		tw2.chain().tween_callback(rim.queue_free)
