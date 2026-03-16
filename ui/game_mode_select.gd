extends CanvasLayer

var selected_mode = "vs"
var selected_map = "vs_map"

func _ready():
	var screen_size = get_viewport().get_visible_rect().size
	
	var bg = ColorRect.new()
	bg.color = Color("#0A0A14")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	# Yıldız efekti
	for i in 30:
		var star = ColorRect.new()
		star.size = Vector2(randf_range(1, 2), randf_range(1, 2))
		star.color = Color(1, 1, 1, randf_range(0.1, 0.5))
		star.position = Vector2(randf_range(0, screen_size.x), randf_range(0, screen_size.y))
		bg.add_child(star)
	
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(640, 460)
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.position -= Vector2(320, 230)
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
	vbox.add_theme_constant_override("separation", 20)
	panel.add_child(vbox)
	
	var title = Label.new()
	title.text = "MOD & HARİTA SEÇ"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color("#9B59B6"))
	vbox.add_child(title)
	
	var sep = HSeparator.new()
	vbox.add_child(sep)
	
	# Mod seçimi
	var mode_label = Label.new()
	mode_label.text = "🎮 OYUN MODU"
	mode_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mode_label.add_theme_color_override("font_color", Color("#9B59B6"))
	mode_label.add_theme_font_size_override("font_size", 16)
	vbox.add_child(mode_label)
	
	var mode_row = HBoxContainer.new()
	mode_row.alignment = BoxContainer.ALIGNMENT_CENTER
	mode_row.add_theme_constant_override("separation", 20)
	vbox.add_child(mode_row)
	
	var vs_btn = _make_mode_button("🗺 VS MODU\nAçık harita\nSonsuz alan\n30 dakika hayatta kal!", "vs", true)
	var brotato_btn = _make_mode_button("⬡ ARENA MODU\nSınırlı alan\nDalga savunma\n🔒 Yakında...", "arena", false)
	brotato_btn.disabled = true
	brotato_btn.modulate.a = 0.35
	mode_row.add_child(vs_btn)
	mode_row.add_child(brotato_btn)
	
	var sep2 = HSeparator.new()
	vbox.add_child(sep2)
	
	# Harita
	var map_label = Label.new()
	map_label.text = "🗺 HARİTA"
	map_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	map_label.add_theme_color_override("font_color", Color("#9B59B6"))
	map_label.add_theme_font_size_override("font_size", 16)
	vbox.add_child(map_label)
	
	var map_row = HBoxContainer.new()
	map_row.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(map_row)
	
	var vs_map_btn = _make_mode_button("🌿 YEŞİL OVAN\nAçık alan\nSonsuz arka plan", "vs_map", true)
	map_row.add_child(vs_map_btn)
	
	var sep3 = HSeparator.new()
	vbox.add_child(sep3)
	
	var btn_row = HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 20)
	vbox.add_child(btn_row)
	
	var back_btn = _make_action_button("← GERİ", Color("#922B21"))
	var play_btn = _make_action_button("▶ BAŞLAT!", Color("#1E8449"))
	back_btn.pressed.connect(_on_back)
	play_btn.pressed.connect(_on_play)
	btn_row.add_child(back_btn)
	btn_row.add_child(play_btn)

func _make_mode_button(text: String, mode_id: String, selected: bool) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(200, 80)
	btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#9B59B6").darkened(0.3) if selected else Color("#1A1A2E")
	style.border_color = Color("#9B59B6") if selected else Color("#333355")
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.pressed.connect(func(): _on_mode_selected(mode_id))
	return btn

func _make_action_button(text: String, color: Color) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(160, 55)
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.add_theme_font_size_override("font_size", 18)
	return btn

func _on_mode_selected(mode_id: String):
	selected_mode = mode_id

func _on_back():
	get_tree().change_scene_to_file("res://ui/character_select.tscn")

func _on_play():
	SaveManager.selected_mode = selected_mode
	SaveManager.selected_map = selected_map
	get_tree().change_scene_to_file("res://main/main.tscn")
