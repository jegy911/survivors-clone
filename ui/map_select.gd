extends CanvasLayer

var selected_map = "vs_map"

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
	panel.custom_minimum_size = Vector2(600, 400)
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.position -= Vector2(300, 200)
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
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 24)
	panel.add_child(vbox)

	var title = Label.new()
	title.text = "HARİTA SEÇ"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color("#9B59B6"))
	vbox.add_child(title)

	vbox.add_child(HSeparator.new())

	var map_row = HBoxContainer.new()
	map_row.alignment = BoxContainer.ALIGNMENT_CENTER
	map_row.add_theme_constant_override("separation", 20)
	vbox.add_child(map_row)

	var map1_btn = _make_btn("🏰 DÜŞMÜŞ KRALLIK\n\nAçık alan\nOrtaçağ kalıntıları\n30 dakika hayatta kal!", Color("#27AE60"))
	var map2_btn = _make_btn("⬡ HARİTA 2\n\nYakında...", Color("#6C3483"))
	var map3_btn = _make_btn("⬡ HARİTA 3\n\nYakında...", Color("#6C3483"))
	map2_btn.disabled = true
	map2_btn.modulate.a = 0.4
	map3_btn.disabled = true
	map3_btn.modulate.a = 0.4

	map1_btn.pressed.connect(func(): _on_map("vs_map"))
	map_row.add_child(map1_btn)
	map_row.add_child(map2_btn)
	map_row.add_child(map3_btn)

	vbox.add_child(HSeparator.new())

	var btn_row = HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 20)
	vbox.add_child(btn_row)

	var back_btn = _make_action_btn("← GERİ", Color("#922B21"))
	var play_btn = _make_action_btn("▶ BAŞLAT!", Color("#1E8449"))
	back_btn.pressed.connect(_on_back)
	play_btn.pressed.connect(_on_play)
	btn_row.add_child(back_btn)
	btn_row.add_child(play_btn)

func _make_btn(text: String, color: Color) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(160, 130)
	btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var style = StyleBoxFlat.new()
	style.bg_color = color.darkened(0.5)
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
	SaveManager.selected_map = selected_map
	SaveManager.save_game()
	get_tree().change_scene_to_file("res://main/main.tscn")
