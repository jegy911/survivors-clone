extends CanvasLayer

var _current_tab: String = CollectionData.TAB_ENEMY
var _selected_entry: Dictionary = {}
var _tab_buttons: Array[Button] = []
var _tab_group: ButtonGroup = ButtonGroup.new()


func _ready() -> void:
	if not LocalizationManager.locale_changed.is_connected(_on_locale_changed):
		LocalizationManager.locale_changed.connect(_on_locale_changed)
	_resize_root()
	_build_starfield()
	_setup_layout()
	_build_tab_buttons()
	$MainVBox/BackButton.pressed.connect(_on_back)
	_apply_texts()
	_refresh_grid()
	_refresh_detail()
	var vp = get_viewport()
	if not vp.size_changed.is_connected(_on_viewport_resized):
		vp.size_changed.connect(_on_viewport_resized)


func _on_locale_changed(_locale: String = "") -> void:
	_apply_texts()
	_refresh_grid()
	_refresh_detail()


func _on_viewport_resized() -> void:
	_resize_root()
	_build_starfield()
	_refresh_grid()


func _resize_root() -> void:
	var sz = get_viewport().get_visible_rect().size
	$Background.size = sz


func _build_starfield() -> void:
	for c in $Background.get_children():
		c.queue_free()
	var sz = $Background.size
	for i in 36:
		var star = ColorRect.new()
		star.size = Vector2(randf_range(1, 3), randf_range(1, 3))
		star.color = Color(1, 1, 1, randf_range(0.15, 0.75))
		star.position = Vector2(randf_range(0, sz.x), randf_range(0, sz.y))
		$Background.add_child(star)
		var st = star.create_tween()
		st.set_loops()
		st.tween_property(star, "modulate:a", 0.08, randf_range(1.2, 2.8))
		st.tween_property(star, "modulate:a", 1.0, randf_range(1.2, 2.8))


func _setup_layout() -> void:
	$Background.color = Color("#08081A")
	var vbox = $MainVBox
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 24
	vbox.offset_top = 20
	vbox.offset_right = -24
	vbox.offset_bottom = -20
	vbox.add_theme_constant_override("separation", 12)
	$MainVBox/TitleLabel.add_theme_font_size_override("font_size", 38)
	$MainVBox/TitleLabel.add_theme_color_override("font_color", Color("#BB8FCE"))
	$MainVBox/ProgressLabel.add_theme_font_size_override("font_size", 15)
	$MainVBox/ProgressLabel.add_theme_color_override("font_color", Color("#8888AA"))
	var title_tween = create_tween()
	title_tween.set_loops()
	title_tween.tween_property($MainVBox/TitleLabel, "modulate", Color(1.0, 0.92, 1.0, 1.0), 1.4)
	title_tween.tween_property($MainVBox/TitleLabel, "modulate", Color(0.75, 0.55, 1.0, 0.9), 1.4)
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.12, 0.1, 0.22, 0.92)
	panel_style.border_color = Color("#6C3483")
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(12)
	$MainVBox/DetailPanel.add_theme_stylebox_override("panel", panel_style)
	var detail_title: Label = $MainVBox/DetailPanel/DetailInner/DetailVBox/DetailTitle
	var detail_desc: Label = $MainVBox/DetailPanel/DetailInner/DetailVBox/DetailDesc
	detail_title.add_theme_font_size_override("font_size", 22)
	detail_title.add_theme_color_override("font_color", Color("#ECF0F1"))
	detail_desc.add_theme_font_size_override("font_size", 15)
	detail_desc.add_theme_color_override("font_color", Color("#BDC3C7"))
	_ensure_detail_icon_row()
	_style_back_button()
	_ensure_world_lore_hint()


func _ensure_detail_icon_row() -> void:
	var vbox: VBoxContainer = $MainVBox/DetailPanel/DetailInner/DetailVBox as VBoxContainer
	if vbox.get_node_or_null("DetailIconWrap") != null:
		return
	var wrap := CenterContainer.new()
	wrap.name = "DetailIconWrap"
	wrap.custom_minimum_size = Vector2(0, 84)
	wrap.visible = false
	var tr_icon := TextureRect.new()
	tr_icon.name = "DetailIcon"
	tr_icon.custom_minimum_size = Vector2(80, 80)
	tr_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	wrap.add_child(tr_icon)
	vbox.add_child(wrap)
	vbox.move_child(wrap, 0)


func _ensure_world_lore_hint() -> void:
	if $MainVBox.get_node_or_null("WorldLoreHint") != null:
		return
	var hint := Label.new()
	hint.name = "WorldLoreHint"
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hint.add_theme_font_size_override("font_size", 12)
	hint.add_theme_color_override("font_color", Color("#6F7F90"))
	hint.text = tr("ui.collection_menu.world_info_hint")
	var pi: int = $MainVBox/ProgressLabel.get_index()
	$MainVBox.add_child(hint)
	$MainVBox.move_child(hint, pi + 1)


func _style_back_button() -> void:
	var btn = $MainVBox/BackButton
	btn.custom_minimum_size = Vector2(220, 52)
	btn.add_theme_font_size_override("font_size", 18)
	var st = StyleBoxFlat.new()
	st.bg_color = Color("#1A5276")
	st.border_color = Color("#2471A3")
	st.set_border_width_all(2)
	st.set_corner_radius_all(10)
	btn.add_theme_stylebox_override("normal", st)
	var h = st.duplicate()
	h.bg_color = Color("#2471A3")
	btn.add_theme_stylebox_override("hover", h)
	btn.add_theme_color_override("font_color", Color.WHITE)


func _build_tab_buttons() -> void:
	var row = $MainVBox/FilterRow
	for c in row.get_children():
		c.queue_free()
	_tab_buttons.clear()
	for tab_id in CollectionData.TAB_ORDER:
		var b = Button.new()
		b.toggle_mode = true
		b.button_group = _tab_group
		b.custom_minimum_size = Vector2(88, 40)
		b.add_theme_font_size_override("font_size", 12)
		b.clip_text = true
		b.text = tr("ui.collection_menu.tab_%s" % tab_id)
		b.set_meta("tab_id", tab_id)
		b.pressed.connect(_on_tab_pressed.bind(tab_id))
		if tab_id == _current_tab:
			b.button_pressed = true
		_style_tab_button(b, tab_id == _current_tab)
		row.add_child(b)
		_tab_buttons.append(b)


func _style_tab_button(btn: Button, on: bool) -> void:
	var st = StyleBoxFlat.new()
	if on:
		st.bg_color = Color("#6C3483")
		st.border_color = Color("#BB8FCE")
	else:
		st.bg_color = Color("#1E1E32")
		st.border_color = Color("#4A4A6A")
	st.set_border_width_all(2)
	st.set_corner_radius_all(8)
	btn.add_theme_stylebox_override("normal", st)
	var h = st.duplicate()
	h.bg_color = Color("#7D3C98")
	btn.add_theme_stylebox_override("hover", h)
	btn.add_theme_color_override("font_color", Color.WHITE)


func _on_tab_pressed(tab_id: String) -> void:
	_current_tab = tab_id
	for b in _tab_buttons:
		var tid = str(b.get_meta("tab_id", ""))
		_style_tab_button(b, tid == _current_tab)
	if not _selected_entry.is_empty() and str(_selected_entry.get("tab", "")) != _current_tab:
		_selected_entry = {}
	_refresh_grid()
	_refresh_detail()


func _entry_name_key(entry: Dictionary) -> String:
	var tab: String = str(entry.get("tab", ""))
	var id: String = str(entry.get("id", ""))
	if tab == CollectionData.TAB_GLOSSARY:
		return CollectionData.glossary_title_key(id)
	if tab == CollectionData.TAB_ENEMY or tab == CollectionData.TAB_BOSS:
		return "codex.%s.name" % id
	return "codex.%s.%s.name" % [tab, id]


func _entry_desc_key(entry: Dictionary) -> String:
	var tab: String = str(entry.get("tab", ""))
	var id: String = str(entry.get("id", ""))
	if tab == CollectionData.TAB_GLOSSARY:
		return CollectionData.glossary_body_key(id)
	if tab == CollectionData.TAB_ENEMY or tab == CollectionData.TAB_BOSS:
		return "codex.%s.desc" % id
	return "codex.%s.%s.desc" % [tab, id]


func _locked_desc_key(entry: Dictionary) -> String:
	var tab: String = str(entry.get("tab", "enemy"))
	if tab == CollectionData.TAB_GLOSSARY:
		return "ui.collection_menu.locked_desc_glossary"
	return "ui.collection_menu.locked_desc_%s" % tab


func _entries_match(a: Dictionary, b: Dictionary) -> bool:
	if a.is_empty() or b.is_empty():
		return false
	return str(a.get("tab", "")) == str(b.get("tab", "")) and str(a.get("id", "")) == str(b.get("id", ""))


func _apply_texts() -> void:
	$MainVBox/TitleLabel.text = tr("ui.collection_menu.title")
	var wl: Node = $MainVBox.get_node_or_null("WorldLoreHint")
	if wl is Label:
		(wl as Label).text = tr("ui.collection_menu.world_info_hint")
	var n = CollectionData.total_entry_count()
	var d = 0
	for e in CollectionData.all_entries():
		if SaveManager.is_codex_entry_unlocked(e):
			d += 1
	$MainVBox/ProgressLabel.text = tr("ui.collection_menu.progress") % [d, n]
	$MainVBox/BackButton.text = tr("ui.collection_menu.back")
	for b in _tab_buttons:
		var tid = str(b.get_meta("tab_id", ""))
		b.text = tr("ui.collection_menu.tab_%s" % tid)


func _refresh_grid() -> void:
	var grid = $MainVBox/ScrollContainer/EntryGrid
	for c in grid.get_children():
		c.queue_free()
	var col_n = 4
	var vw = get_viewport().get_visible_rect().size.x
	if vw < 1100:
		col_n = 3
	if vw < 780:
		col_n = 2
	grid.columns = col_n
	for entry in CollectionData.entries_for_tab(_current_tab):
		grid.add_child(_make_card(entry))


func _card_style(entry: Dictionary, discovered: bool, selected: bool) -> StyleBoxFlat:
	var accent = Color(str(entry.get("accent", "#666666")))
	var st = StyleBoxFlat.new()
	st.set_corner_radius_all(14)
	st.set_border_width_all(3 if selected else 2)
	if selected:
		st.border_color = Color("#F4D03F")
	elif discovered:
		st.border_color = accent.lightened(0.15)
	else:
		st.border_color = Color("#2C2C3E")
	if discovered:
		st.bg_color = Color(accent.r * 0.22, accent.g * 0.22, accent.b * 0.22, 0.95)
	else:
		st.bg_color = Color(0.08, 0.08, 0.12, 0.9)
	return st


func _make_card(entry: Dictionary) -> PanelContainer:
	var discovered = SaveManager.is_codex_entry_unlocked(entry)
	var selected = _entries_match(_selected_entry, entry)
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(104, 118)
	panel.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var st = _card_style(entry, discovered, selected)
	panel.add_theme_stylebox_override("panel", st)
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)
	var inner = VBoxContainer.new()
	inner.add_theme_constant_override("separation", 6)
	margin.add_child(inner)
	var icon_wrap := CenterContainer.new()
	icon_wrap.custom_minimum_size = Vector2(44, 44)
	inner.add_child(icon_wrap)
	if discovered:
		var tex: Texture2D = CodexIconCatalog.try_for_entry(entry)
		if tex != null:
			var tr_icon := TextureRect.new()
			tr_icon.texture = tex
			tr_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tr_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tr_icon.custom_minimum_size = Vector2(44, 44)
			icon_wrap.add_child(tr_icon)
		else:
			var emoji := Label.new()
			emoji.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			emoji.text = str(entry.get("emoji", "•"))
			emoji.add_theme_font_size_override("font_size", 32)
			icon_wrap.add_child(emoji)
	else:
		var lock_l := Label.new()
		lock_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lock_l.text = "❔"
		lock_l.add_theme_font_size_override("font_size", 28)
		lock_l.modulate = Color(0.45, 0.45, 0.55, 1.0)
		icon_wrap.add_child(lock_l)
	var name_l = Label.new()
	name_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_l.add_theme_font_size_override("font_size", 13)
	if discovered:
		name_l.text = tr(_entry_name_key(entry))
		name_l.add_theme_color_override("font_color", Color("#ECF0F1"))
	else:
		name_l.text = tr("ui.collection_menu.locked_short")
		name_l.add_theme_color_override("font_color", Color("#5C5C70"))
	inner.add_child(name_l)
	panel.set_meta("entry_dict", entry)
	panel.gui_input.connect(_on_card_gui_input.bind(panel))
	panel.mouse_entered.connect(_on_card_hover.bind(panel, true))
	panel.mouse_exited.connect(_on_card_hover.bind(panel, false))
	return panel


func _on_card_hover(panel: PanelContainer, inside: bool) -> void:
	var entry: Dictionary = panel.get_meta("entry_dict")
	var discovered = SaveManager.is_codex_entry_unlocked(entry)
	var selected = _entries_match(_selected_entry, entry)
	var st = _card_style(entry, discovered, selected)
	if inside and not selected:
		st.bg_color = st.bg_color.lightened(0.08)
	panel.add_theme_stylebox_override("panel", st)


func _on_card_gui_input(event: InputEvent, panel: PanelContainer) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_card_pressed(panel.get_meta("entry_dict"))


func _on_card_pressed(entry: Dictionary) -> void:
	_selected_entry = entry.duplicate()
	_refresh_grid()
	_refresh_detail()


func _refresh_detail() -> void:
	var title: Label = $MainVBox/DetailPanel/DetailInner/DetailVBox/DetailTitle
	var desc: Label = $MainVBox/DetailPanel/DetailInner/DetailVBox/DetailDesc
	var wrap: CenterContainer = $MainVBox/DetailPanel/DetailInner/DetailVBox.get_node_or_null("DetailIconWrap") as CenterContainer
	var dicon: TextureRect = null
	if wrap != null:
		dicon = wrap.get_node_or_null("DetailIcon") as TextureRect
	if _selected_entry.is_empty():
		title.text = tr("ui.collection_menu.pick_title")
		desc.text = tr("ui.collection_menu.pick_desc")
		if wrap != null:
			wrap.visible = false
		return
	var discovered = SaveManager.is_codex_entry_unlocked(_selected_entry)
	if discovered:
		title.text = tr(_entry_name_key(_selected_entry))
		desc.text = tr(_entry_desc_key(_selected_entry))
		if dicon != null:
			var tex: Texture2D = CodexIconCatalog.try_for_entry(_selected_entry)
			if tex != null:
				dicon.texture = tex
				wrap.visible = true
			else:
				dicon.texture = null
				wrap.visible = false
	else:
		title.text = tr("ui.collection_menu.locked_name")
		desc.text = tr(_locked_desc_key(_selected_entry))
		if dicon != null:
			dicon.texture = null
			wrap.visible = false


func _on_back() -> void:
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")


func _unhandled_input(event: InputEvent) -> void:
	if not MenuInput.is_menu_back_pressed(event):
		return
	get_viewport().set_input_as_handled()
	if not _selected_entry.is_empty():
		_selected_entry = {}
		_refresh_grid()
		_refresh_detail()
		return
	_on_back()
