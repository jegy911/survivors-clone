extends CanvasLayer

var selected_mode = "vs"
var selected_map = "vs_map"
var map_row: HBoxContainer = null

func _ready():
	var screen_size = get_viewport().get_visible_rect().size
	var bg = ColorRect.new()
	bg.color = Color("#0A0A14")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	for i in 30:
		var star = ColorRect.new()
		star.size = Vector2(randf_range(1, 2), randf_range(1, 2))
		star.color = Color(1, 1, 1, randf_range(0.1, 0.5))
		star.position = Vector2(randf_range(0, screen_size.x), randf_range(0, screen_size.y))
		bg.add_child(star)

	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(680, 500)
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.position -= Vector2(340, 250)
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#0D0D1A")
	style.border_color = Color("#9B59B6")
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.name = "VBox"
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 20)
	panel.add_child(vbox)

	var title = Label.new()
	title.text = tr("ui.map_select.title")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color("#9B59B6"))
	vbox.add_child(title)

	vbox.add_child(HSeparator.new())

	# Oyun modu seçimi
	var mode_label = Label.new()
	mode_label.text = tr("ui.map_select.mode_label")
	mode_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mode_label.add_theme_color_override("font_color", Color("#9B59B6"))
	mode_label.add_theme_font_size_override("font_size", 16)
	vbox.add_child(mode_label)

	var mode_row = HBoxContainer.new()
	mode_row.alignment = BoxContainer.ALIGNMENT_CENTER
	mode_row.add_theme_constant_override("separation", 16)
	vbox.add_child(mode_row)

	var vs_btn = _make_btn(tr("ui.map_select.vs_mode"), Color("#27AE60"), true)
	var arena_btn = _make_btn(tr("ui.map_select.arena_mode"), Color("#6C3483"), false)
	arena_btn.disabled = true
	arena_btn.modulate.a = 0.4
	vs_btn.pressed.connect(func(): _on_mode_selected("vs", vs_btn, arena_btn))
	arena_btn.pressed.connect(func(): _on_mode_selected("arena", arena_btn, vs_btn))
	mode_row.add_child(vs_btn)
	mode_row.add_child(arena_btn)

	vbox.add_child(HSeparator.new())

	# Harita başlığı
	var map_label = Label.new()
	map_label.text = tr("ui.map_select.map_label")
	map_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	map_label.add_theme_color_override("font_color", Color("#9B59B6"))
	map_label.add_theme_font_size_override("font_size", 16)
	vbox.add_child(map_label)

	# Harita satırı
	map_row = HBoxContainer.new()
	map_row.name = "MapRow"
	map_row.alignment = BoxContainer.ALIGNMENT_CENTER
	map_row.add_theme_constant_override("separation", 16)
	vbox.add_child(map_row)
	_build_maps("vs")

	vbox.add_child(HSeparator.new())

	var btn_row = HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 20)
	vbox.add_child(btn_row)

	var back_btn = _make_action_btn(tr("ui.map_select.back"), Color("#922B21"))
	var play_btn = _make_action_btn(tr("ui.map_select.start"), Color("#1E8449"))
	back_btn.pressed.connect(_on_back)
	play_btn.pressed.connect(_on_play)
	btn_row.add_child(back_btn)
	btn_row.add_child(play_btn)

func _build_maps(mode: String):
	for child in map_row.get_children():
		child.queue_free()
	if mode == "vs":
		var map1 = _make_btn(tr("ui.map_select.map1"), Color("#27AE60"), true)
		var map2 = _make_btn(tr("ui.map_select.map2"), Color("#6C3483"), false)
		var map3 = _make_btn(tr("ui.map_select.map3"), Color("#6C3483"), false)
		map2.disabled = true
		map2.modulate.a = 0.4
		map3.disabled = true
		map3.modulate.a = 0.4
		map1.pressed.connect(func(): _on_map("vs_map"))
		selected_map = "vs_map"
		map_row.add_child(map1)
		map_row.add_child(map2)
		map_row.add_child(map3)
	else:
		var arena1 = _make_btn(tr("ui.map_select.arena1"), Color("#6C3483"), false)
		arena1.disabled = true
		arena1.modulate.a = 0.4
		map_row.add_child(arena1)

func _on_mode_selected(mode: String, selected_btn: Button, other_btn: Button):
	selected_mode = mode
	# Seçili buton görselini güncelle
	var sel_style = selected_btn.get_theme_stylebox("normal").duplicate()
	sel_style.bg_color = Color("#27AE60").darkened(0.2) if mode == "vs" else Color("#6C3483").darkened(0.2)
	selected_btn.add_theme_stylebox_override("normal", sel_style)
	_build_maps(mode)

func _make_btn(text: String, color: Color, selected: bool = false) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(160, 130)
	btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var style = StyleBoxFlat.new()
	style.bg_color = color.darkened(0.2) if selected else color.darkened(0.5)
	style.border_color = color
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	btn.add_theme_stylebox_override("normal", style)
	var hover = style.duplicate()
	hover.bg_color = color.darkened(0.2)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.add_theme_font_size_override("font_size", 14)
	return btn

func _make_action_btn(text: String, color: Color) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(160, 50)
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.add_theme_font_size_override("font_size", 16)
	return btn

func _on_map(map_id: String):
	selected_map = map_id

func _on_back():
	if SaveManager.game_mode == "local_coop":
		get_tree().change_scene_to_file("res://ui/character_select_p2.tscn")
	else:
		get_tree().change_scene_to_file("res://ui/character_select.tscn")

func _on_play():
	SaveManager.selected_mode = selected_mode
	SaveManager.selected_map = selected_map
	SaveManager.register_codex_map(selected_map)
	SaveManager.save_game()
	get_tree().change_scene_to_file("res://main/main.tscn")
