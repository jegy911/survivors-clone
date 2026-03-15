extends CanvasLayer

var selected_mode = "vs"
var selected_map = "vs_map"

func _ready():
	var screen_size = get_viewport().get_visible_rect().size
	
	var bg = ColorRect.new()
	bg.color = Color("#0D0D1A")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
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
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)
	
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 24)
	panel.add_child(vbox)
	
	var title = Label.new()
	title.text = "MOD & HARİTA SEÇ"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color("#9B59B6"))
	vbox.add_child(title)
	
	var sep = HSeparator.new()
	vbox.add_child(sep)
	
	# Mod seçimi
	var mode_label = Label.new()
	mode_label.text = "🎮 Oyun Modu"
	mode_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mode_label.add_theme_color_override("font_color", Color("#AAAAAA"))
	vbox.add_child(mode_label)
	
	var mode_row = HBoxContainer.new()
	mode_row.alignment = BoxContainer.ALIGNMENT_CENTER
	mode_row.add_theme_constant_override("separation", 16)
	vbox.add_child(mode_row)
	
	var vs_btn = _make_mode_button("🗺 VS Modu\nAçık harita, sonsuz alan", "vs", true)
	var brotato_btn = _make_mode_button("⬡ Arena Modu\nYakında...", "arena", false)
	brotato_btn.disabled = true
	brotato_btn.modulate.a = 0.4
	mode_row.add_child(vs_btn)
	mode_row.add_child(brotato_btn)
	
	var sep2 = HSeparator.new()
	vbox.add_child(sep2)
	
	# Harita seçimi
	var map_label = Label.new()
	map_label.text = "🗺 Harita"
	map_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	map_label.add_theme_color_override("font_color", Color("#AAAAAA"))
	vbox.add_child(map_label)
	
	var map_row = HBoxContainer.new()
	map_row.alignment = BoxContainer.ALIGNMENT_CENTER
	map_row.add_theme_constant_override("separation", 16)
	vbox.add_child(map_row)
	
	var vs_map_btn = _make_mode_button("🌿 VS Haritası\nAçık yeşil alan", "vs_map", true)
	map_row.add_child(vs_map_btn)
	
	var sep3 = HSeparator.new()
	vbox.add_child(sep3)
	
	# Alt butonlar
	var btn_row = HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 16)
	vbox.add_child(btn_row)
	
	var back_btn = _make_action_button("← Geri", Color("#1A1A2E"))
	var play_btn = _make_action_button("▶ Başlat", Color("#27AE60"))
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
