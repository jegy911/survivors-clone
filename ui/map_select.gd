extends CanvasLayer

const MAP_IDS_VS := ["vs_map"]
const CURSE_BAR_SCRIPT: GDScript = preload("res://ui/run_curse_stat_bar.gd")

var _variant: String = "story"
var _map_id: String = "vs_map"
var _curse_tier: int = 0
var _map_column: VBoxContainer
var _preview: TextureRect
var _desc: RichTextLabel
var _curse_value: Label
var _mode_entries: Array = []
var _map_ui_scale: float = 1.0
## { "kind": String, "bar": Control, "l0": Label, "l1": Label, "l2": Label }
var _curse_rows: Array = []


func _ready() -> void:
	var s: float = SaveManager.get_ui_scale()
	_map_ui_scale = s

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
	left.custom_minimum_size = Vector2(int(332 * s), 0)
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
	curse_slider.max_value = float(SaveManager.RUN_CURSE_TIER_MAX)
	curse_slider.step = 1
	curse_slider.value = float(SaveManager.settings.get("run_curse_tier", SaveManager.RUN_CURSE_REFERENCE_TIER))
	curse_slider.custom_minimum_size = Vector2(int(300 * s), int(28 * s))
	curse_slider.value_changed.connect(_on_curse_changed)
	left.add_child(curse_slider)

	var curse_detail := _build_curse_factors_panel(s)
	left.add_child(curse_detail)
	_on_curse_changed(curse_slider.value)

	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 12)
	left.add_child(btn_row)
	btn_row.add_child(_action_btn(tr("ui.map_select.back"), s, 1))
	btn_row.add_child(_action_btn(tr("ui.map_select.start"), s, 0))
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
	b.set_meta("btn_cover_variant", _mode_entries.size() % 3)
	_style_list_btn(b, false)
	b.pressed.connect(func(): _set_variant(id))
	parent.add_child(b)
	_mode_entries.append({"id": id, "btn": b})


func _style_list_btn(b: Button, sel: bool) -> void:
	var v: int = int(b.get_meta("btn_cover_variant", 0))
	var inset := Vector4(12.0, 6.0, 12.0, 6.0) * _map_ui_scale
	var mod := Color(1.06, 0.98, 1.12, 1.0) if sel else Color(0.64, 0.64, 0.7, 1.0)
	ButtonCoverStyles.apply(b, v, int(15.0 * _map_ui_scale), inset, mod)


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
	for idx in MAP_IDS_VS.size():
		var mid: String = MAP_IDS_VS[idx]
		var mb := Button.new()
		mb.text = tr("ui.map_select.map1") if mid == "vs_map" else mid
		mb.custom_minimum_size = Vector2(0, 36)
		mb.alignment = HORIZONTAL_ALIGNMENT_LEFT
		mb.set_meta("btn_cover_variant", idx % 3)
		_style_list_btn(mb, mid == _map_id)
		mb.pressed.connect(_select_map.bind(mid))
		_map_column.add_child(mb)


func _select_map(mid: String) -> void:
	_map_id = mid
	_rebuild_map_buttons()
	_update_preview()


func _on_curse_changed(v: float) -> void:
	_curse_tier = int(round(v))
	var fmt: String = tr("ui.map_select.curse_value")
	if fmt.count("%") >= 2:
		_curse_value.text = fmt % [_curse_tier, SaveManager.RUN_CURSE_TIER_MAX]
	else:
		_curse_value.text = fmt % _curse_tier
	_refresh_curse_stat_rows(_curse_tier)


func _build_curse_factors_panel(s: float) -> VBoxContainer:
	_curse_rows.clear()
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", int(10 * s))

	var intro := Label.new()
	intro.text = LocalizationManager.tr_en_source("ui.map_select.curse_intro")
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intro.add_theme_font_size_override("font_size", int(11 * s))
	intro.add_theme_color_override("font_color", Color("#A8B0C4"))
	intro.custom_minimum_size = Vector2(int(308 * s), 0)
	col.add_child(intro)

	var note := Label.new()
	note.text = LocalizationManager.tr_en_source("ui.map_select.curse_meta_note")
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.add_theme_font_size_override("font_size", int(10 * s))
	note.add_theme_color_override("font_color", Color("#6B7280"))
	note.custom_minimum_size = Vector2(int(308 * s), 0)
	col.add_child(note)

	var defs: Array[Dictionary] = [
		{
			"kind": "spawn",
			"title": "ui.map_select.curse_stat_spawn_title",
			"desc": "ui.map_select.curse_stat_spawn_desc",
		},
		{
			"kind": "hp",
			"title": "ui.map_select.curse_stat_hp_title",
			"desc": "ui.map_select.curse_stat_hp_desc",
		},
		{
			"kind": "speed",
			"title": "ui.map_select.curse_stat_speed_title",
			"desc": "ui.map_select.curse_stat_speed_desc",
		},
		{
			"kind": "xp",
			"title": "ui.map_select.curse_stat_xp_title",
			"desc": "ui.map_select.curse_stat_xp_desc",
		},
	]
	for def in defs:
		col.add_child(_make_one_curse_stat_row(def, s))
	return col


func _make_one_curse_stat_row(def: Dictionary, s: float) -> Control:
	var wrap := VBoxContainer.new()
	wrap.add_theme_constant_override("separation", int(4 * s))

	var title := Label.new()
	title.text = LocalizationManager.tr_en_source(str(def["title"]))
	title.add_theme_font_size_override("font_size", int(12 * s))
	title.add_theme_color_override("font_color", Color("#DDE4FF"))
	wrap.add_child(title)

	var desc := Label.new()
	desc.text = LocalizationManager.tr_en_source(str(def["desc"]))
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.custom_minimum_size = Vector2(int(308 * s), 0)
	desc.add_theme_font_size_override("font_size", int(10 * s))
	desc.add_theme_color_override("font_color", Color("#7D8AA6"))
	wrap.add_child(desc)

	var bar: Control = CURSE_BAR_SCRIPT.new() as Control
	bar.custom_minimum_size = Vector2(int(300 * s), int(12 * s))
	wrap.add_child(bar)

	var nums := HBoxContainer.new()
	nums.add_theme_constant_override("separation", int(6 * s))
	var l0 := Label.new()
	var l1 := Label.new()
	var l2 := Label.new()
	for L: Label in [l0, l1, l2]:
		L.add_theme_font_size_override("font_size", int(10 * s))
		L.add_theme_color_override("font_color", Color("#B8C0D4"))
	l0.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l0.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	l1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l2.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	nums.add_child(l0)
	nums.add_child(l1)
	nums.add_child(l2)
	wrap.add_child(nums)

	_curse_rows.append({"kind": str(def["kind"]), "bar": bar, "l0": l0, "l1": l1, "l2": l2})
	return wrap


func _refresh_curse_stat_rows(tier: int) -> void:
	var tmax: int = SaveManager.RUN_CURSE_TIER_MAX
	for row in _curse_rows:
		var kind: String = str(row["kind"])
		var v0: int
		var v5: int
		var vc: int
		match kind:
			"spawn":
				v0 = SaveManager.run_curse_spawn_percent_for_tier(0)
				v5 = SaveManager.run_curse_spawn_percent_for_tier(tmax)
				vc = SaveManager.run_curse_spawn_percent_for_tier(tier)
			"hp":
				v0 = SaveManager.run_curse_enemy_hp_percent_for_tier(0)
				v5 = SaveManager.run_curse_enemy_hp_percent_for_tier(tmax)
				vc = SaveManager.run_curse_enemy_hp_percent_for_tier(tier)
			"speed":
				v0 = SaveManager.run_curse_enemy_speed_percent_for_tier(0)
				v5 = SaveManager.run_curse_enemy_speed_percent_for_tier(tmax)
				vc = SaveManager.run_curse_enemy_speed_percent_for_tier(tier)
			"xp":
				v0 = SaveManager.run_curse_xp_gain_percent_for_tier(0)
				v5 = SaveManager.run_curse_xp_gain_percent_for_tier(tmax)
				vc = SaveManager.run_curse_xp_gain_percent_for_tier(tier)
			_:
				continue
		(row["bar"] as Node).call("set_scale_values", float(v0), float(v5), float(vc))
		row["l0"].text = LocalizationManager.tr_en_source("ui.map_select.curse_scale_t0") % v0
		row["l1"].text = LocalizationManager.tr_en_source("ui.map_select.curse_scale_pick") % vc
		row["l2"].text = LocalizationManager.tr_en_source("ui.map_select.curse_scale_tmax") % [tmax, v5]


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


func _action_btn(txt: String, s: float, cover_variant: int) -> Button:
	var b := Button.new()
	b.text = txt
	b.custom_minimum_size = Vector2(int(140 * s), int(48 * s))
	b.add_theme_font_size_override("font_size", int(15 * s))
	ButtonCoverStyles.apply(
		b,
		cover_variant,
		int(15 * s),
		Vector4(14.0, 7.0, 14.0, 7.0) * s,
		Color.WHITE,
		Color.WHITE,
	)
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
