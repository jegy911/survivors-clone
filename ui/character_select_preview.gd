class_name CharacterSelectPreview
extends RefCounted
## Karakter sahnesindeki `AnimatedSprite2D` → `idle_left` (yoksa yedek) ilk karesi önbelleğe alınır.
## SubViewport yok: kartlar hızlı açılır. Çerçeve boyutu sabit.

const INNER_SIZE: Vector2 = Vector2(136, 136)
const FRAME_PAD: int = 4

static var _tex_cache: Dictionary = {} ## char_id -> Texture2D
static var _miss_cache: Dictionary = {} ## char_id -> true (sahne yok / sprite yok)

## `visibility`: "locked" siyah kutu (sahne yüklenmez); "silhouette" gri yarı saydam; "full" tam renk.
static func make_portrait(char_id: String, visibility: String, accent: Color = Color("#333355")) -> Control:
	var outer := _make_outer_frame()
	var inner := MarginContainer.new()
	inner.add_theme_constant_override("margin_left", FRAME_PAD)
	inner.add_theme_constant_override("margin_right", FRAME_PAD)
	inner.add_theme_constant_override("margin_top", FRAME_PAD)
	inner.add_theme_constant_override("margin_bottom", FRAME_PAD)
	inner.custom_minimum_size = INNER_SIZE + Vector2(FRAME_PAD * 2, FRAME_PAD * 2)
	outer.add_child(inner)

	match visibility:
		"locked":
			var blk := ColorRect.new()
			blk.custom_minimum_size = INNER_SIZE
			blk.color = Color(0.02, 0.02, 0.03, 1.0)
			inner.add_child(blk)
		"silhouette", "taken":
			_add_textured_portrait(inner, char_id, accent, true)
		"full", _:
			_add_textured_portrait(inner, char_id, accent, false)

	outer.custom_minimum_size = inner.custom_minimum_size
	outer.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	return outer


static func _make_outer_frame() -> PanelContainer:
	var frame := PanelContainer.new()
	var pstyle := StyleBoxFlat.new()
	pstyle.bg_color = Color(0.06, 0.06, 0.1, 1.0)
	pstyle.set_corner_radius_all(10)
	pstyle.border_width_left = 1
	pstyle.border_width_right = 1
	pstyle.border_width_top = 1
	pstyle.border_width_bottom = 1
	pstyle.border_color = Color(0.2, 0.2, 0.28, 1.0)
	frame.add_theme_stylebox_override("panel", pstyle)
	return frame


static func _add_textured_portrait(inner: MarginContainer, char_id: String, accent: Color, silhouette: bool) -> void:
	var tex: Texture2D = get_portrait_texture(char_id)
	if tex == null:
		var ph := ColorRect.new()
		ph.custom_minimum_size = INNER_SIZE
		ph.color = accent.darkened(0.65) if silhouette else accent.darkened(0.4)
		ph.modulate.a = 0.45 if silhouette else 1.0
		inner.add_child(ph)
		return
	var portrait_texrect := TextureRect.new()
	portrait_texrect.texture = tex
	portrait_texrect.custom_minimum_size = INNER_SIZE
	portrait_texrect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait_texrect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if silhouette:
		portrait_texrect.modulate = Color(0.55, 0.58, 0.64, 0.48)
	else:
		portrait_texrect.modulate = Color.WHITE
	inner.add_child(portrait_texrect)


## İlk kare dokusu (idle_left öncelikli). Önbellekli.
static func get_portrait_texture(char_id: String) -> Texture2D:
	if _tex_cache.has(char_id):
		return _tex_cache[char_id]
	if _miss_cache.has(char_id):
		return null
	var path: String = CharacterData.get_character_scene_path(char_id)
	var ps: PackedScene = load(path) as PackedScene
	if ps == null:
		_miss_cache[char_id] = true
		return null
	var inst: Node = ps.instantiate()
	var src: AnimatedSprite2D = _find_first_animated_sprite(inst)
	var tex: Texture2D = null
	if src != null and src.sprite_frames != null:
		_pick_idle_left_first(src)
		var anim: StringName = src.animation
		var sf: SpriteFrames = src.sprite_frames
		if sf.get_frame_count(anim) > 0:
			tex = sf.get_frame_texture(anim, 0)
	inst.queue_free()
	if tex != null:
		_tex_cache[char_id] = tex
	else:
		_miss_cache[char_id] = true
	return tex


## Oyun modu ekranında veya yükleme sırasında çağrılır; kareleri kademeli önbelleğe alır.
static func warmup_portraits_async(tree: SceneTree, batch: int = 3) -> void:
	var ids: Array[String] = []
	for c in CharacterData.CHARACTERS:
		ids.append(str(c["id"]))
	var n := 0
	for id in ids:
		if not _tex_cache.has(id) and not _miss_cache.has(id):
			get_portrait_texture(id)
			n += 1
			if n % batch == 0:
				await tree.process_frame


static func _find_first_animated_sprite(n: Node) -> AnimatedSprite2D:
	if n is AnimatedSprite2D:
		return n as AnimatedSprite2D
	for c in n.get_children():
		var r := _find_first_animated_sprite(c)
		if r != null:
			return r
	return null


static func _pick_idle_left_first(spr: AnimatedSprite2D) -> void:
	var sf: SpriteFrames = spr.sprite_frames
	if sf == null:
		return
	var names: PackedStringArray = sf.get_animation_names()
	if names.is_empty():
		return
	if names.has(&"idle_left"):
		spr.animation = &"idle_left"
		return
	for cand in [
		&"idle_down", &"idle_right", &"idle_up",
		&"idle", &"stand", &"default",
		&"walk_left", &"walk_down",
	]:
		if names.has(cand):
			spr.animation = cand
			return
	spr.animation = names[0]
