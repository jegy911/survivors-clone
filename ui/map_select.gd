extends CanvasLayer

const MAP_IDS_VS := ["vs_map"]

var _variant: String = "story"
var _map_id: String = "vs_map"
var _curse_tier: int = 0
var _map_column: VBoxContainer
var _preview: TextureRect
var _desc: RichTextLabel
var _curse_value: Label
var _mode_entries: Array = []


func _ready() -> void:
	var s: float = SaveManager.get_ui_scale()

	var bg := ColorRect.new()
	bg.color = Color("#0A0A14")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var root := MarginContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("margin_left", int(20 * s))
	root.add_theme_constant_override("margin_right", int(20 * s))
	root.add_theme_constant_override("margin_top", int(16 * s))
	root.add_theme_constant_override("margin_bottom", int(16 * s))
	add_child(root)

	var hsplit := HBoxContainer.new()
	hsplit.add_theme_constant_override("separation", int(24 * s))
	hsplit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hsplit.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(hsplit)

	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(int(300 * s), 0)
	left.add_theme_constant_override("separation", int(14 * s))
	hsplit.add_child(left)

	var title := Label.new()
	title.text = tr("ui.map_select.title")
	title.add_theme_font_size_override("font_size", int(26 * s))
	title.add_theme_color_override("font_color", Color("#9B59B6"))
	left.add_child(title)

	left.add_child(HSeparator.new())

	var ml := Label.new()
	ml.text = tr("ui.map_select.mode_label")
	ml.add_theme_color_override("font_color", Color("#AAAAAA"))
	ml.add_theme_font_size_override("font_size", int(14 * s))
	left.add_child(ml)

	var mode_col := VBoxContainer.new()
	mode_col.add_theme_constant_override("separation", 8)
	left.add_child(mode_col)
	_register_mode_btn(mode_col, "story", "ui.map_select.mode_story", s)
	_register_mode_btn(mode_col, "fast", "ui.map_select.mode_fast", s)
	_register_mode_btn(mode_col, "arena", "ui.map_select.mode_arena", s, false)

	left.add_child(HSeparator.new())

	var hl := Label.new()
	hl.text = tr("ui.map_select.map_label")
	hl.add_theme_color_override("font_color", Color("#AAAAAA"))
	hl.add_theme_font_size_override("font_size", int(14 * s))
	left.add_child(hl)

	_map_column = VBoxContainer.new()
	_map_column.add_theme_constant_override("separation", 8)
	left.add_child(_map_column)

	left.add_child(HSeparator.new())

	var cl := Label.new()
	cl.text = tr("ui.map_select.curse_label")
	cl.add_theme_color_override("font_color", Color("#AAAAAA"))
	cl.add_theme_font_size_override("font_size", int(14 * s))
	left.add_child(cl)

	_curse_value = Label.new()
	_curse_value.add_theme_color_override("font_color", Color.WHITE)
	_curse_value.add_theme_font_size_override("font_size", int(15 * s))
	left.add_child(_curse_value)

	var curse_slider := HSlider.new()
	curse_slider.min_value = 0
	curse_slider.max_value = 5
	curse_slider.step = 1
	curse_slider.value = float(SaveManager.settings.get("run_curse_tier", 0))
	curse_slider.custom_minimum_size = Vector2(int(260 * s), int(28 * s))
	curse_slider.value_changed.connect(_on_curse_changed)
	left.add_child(curse_slider)
	_on_curse_changed(curse_slider.value)

	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 12)
	left.add_child(btn_row)
	btn_row.add_child(_action_btn(tr("ui.map_select.back"), Color("#922B21"), s))
	btn_row.add_child(_action_btn(tr("ui.map_select.start"), Color("#1E8449"), s))
	btn_row.get_child(0).pressed.connect(_on_back)
	btn_row.get_child(1).pressed.connect(_on_play)

	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", int(12 * s))
	hsplit.add_child(right)

	_preview = TextureRect.new()
	_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_preview.custom_minimum_size = Vector2(int(400 * s), int(280 * s))
	_preview.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var pnl := PanelContainer.new()
	pnl.size_flags_vertical = Control.SIZE_EXPAND_FILL
	pnl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var ps := StyleBoxFlat.new()
	ps.bg_color = Color("#12121f")
	ps.border_color = Color("#9B59B6")
	ps.set_border_width_all(2)
	ps.set_corner_radius_all(12)
	pnl.add_theme_stylebox_override("panel", ps)
	pnl.add_child(_preview)
	right.add_child(pnl)

	_desc = RichTextLabel.new()
	_desc.bbcode_enabled = true
	_desc.fit_content = true
	_desc.scroll_active = false
	_desc.custom_minimum_size = Vector2(200, int(80 * s))
	_desc.add_theme_color_override("default_color", Color("#CCCCCC"))
	_desc.add_theme_font_size_override("normal_font_size", int(14 * s))
	right.add_child(_desc)

	_sync_mode_styles()
	_rebuild_map_buttons()
	_update_preview()


func _register_mode_btn(parent: Node, id: String, tr_key: String, s: float, disabled: bool = false) -> void:
	var b := Button.new()
	b.text = tr(tr_key)
	b.disabled = disabled
	b.modulate.a = 0.45 if disabled else 1.0
	b.custom_minimum_size = Vector2(0, int(40 * s))
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.add_theme_font_size_override("font_size", int(15 * s))
	_style_list_btn(b, false)
	b.pressed.connect(func(): _set_variant(id))
	parent.add_child(b)
	_mode_entries.append({"id": id, "btn": b})


func _style_list_btn(b: Button, sel: bool) -> void:
	var st := StyleBoxFlat.new()
	st.bg_color = Color("#3d2a5c") if sel else Color("#1A1A2E")
	st.set_corner_radius_all(8)
	b.add_theme_stylebox_override("normal", st)
	b.add_theme_color_override("font_color", Color.WHITE)


func _sync_mode_styles() -> void:
	for e in _mode_entries:
		var id: String = str(e["id"])
		var b: Button = e["btn"]
		if b.disabled:
			continue
		_style_list_btn(b, id == _variant)


func _set_variant(id: String) -> void:
	_variant = id
	_sync_mode_styles()
	_rebuild_map_buttons()
	_update_preview()


func _rebuild_map_buttons() -> void:
	for c in _map_column.get_children():
		c.queue_free()
	for mid in MAP_IDS_VS:
		var mb := Button.new()
		mb.text = tr("ui.map_select.map1") if mid == "vs_map" else mid
		mb.custom_minimum_size = Vector2(0, 36)
		mb.alignment = HORIZONTAL_ALIGNMENT_LEFT
		_style_list_btn(mb, mid == _map_id)
		mb.pressed.connect(_select_map.bind(mid))
		_map_column.add_child(mb)


func _select_map(mid: String) -> void:
	_map_id = mid
	_rebuild_map_buttons()
	_update_preview()


func _on_curse_changed(v: float) -> void:
	_curse_tier = int(round(v))
	_curse_value.text = tr("ui.map_select.curse_value") % _curse_tier


func _update_preview() -> void:
	var path: String = CodexIconCatalog.map_preview_path(_map_id)
	var tex: Texture2D = UpgradeIconCatalog.try_texture_at(path)
	_preview.texture = tex
	var body: String
	if _variant == "fast":
		body = tr("ui.map_select.desc_fast")
	elif _variant == "arena":
		body = tr("ui.map_select.desc_arena")
	else:
		body = tr("ui.map_select.desc_story")
	_desc.text = "[center]" + body + "[/center]"


func _action_btn(txt: String, bg: Color, s: float) -> Button:
	var b := Button.new()
	b.text = txt
	b.custom_minimum_size = Vector2(int(120 * s), int(44 * s))
	b.add_theme_font_size_override("font_size", int(15 * s))
	var st := StyleBoxFlat.new()
	st.bg_color = bg
	st.set_corner_radius_all(8)
	b.add_theme_stylebox_override("normal", st)
	b.add_theme_color_override("font_color", Color.WHITE)
	return b


func _on_back() -> void:
	if SaveManager.game_mode == "local_coop":
		get_tree().change_scene_to_file("res://ui/character_select_p2.tscn")
	else:
		get_tree().change_scene_to_file("res://ui/character_select.tscn")


func _unhandled_input(event: InputEvent) -> void:
	if MenuInput.is_menu_back_pressed(event):
		get_viewport().set_input_as_handled()
		_on_back()


func _on_play() -> void:
	SaveManager.settings["run_variant"] = "arena" if _variant == "arena" else _variant
	SaveManager.settings["run_curse_tier"] = _curse_tier
	SaveManager.selected_mode = "vs"
	SaveManager.selected_map = _map_id
	SaveManager.register_codex_map(_map_id)
	SaveManager.save_game()
	get_tree().change_scene_to_file("res://main/main.tscn")
