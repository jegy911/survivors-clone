extends CanvasLayer

func _ready():
	var screen_size = get_viewport().get_visible_rect().size
	$Panel.size = Vector2(600, 580)
	$Panel.position = screen_size / 2 - $Panel.size / 2
	
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
	$Panel.add_theme_stylebox_override("panel", style)
	
	$Panel/VBoxContainer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	$Panel/VBoxContainer.alignment = BoxContainer.ALIGNMENT_CENTER
	$Panel/VBoxContainer.add_theme_constant_override("separation", 10)

func show_stats(time: float, level: int, kills: int, gold: int, won: bool = false):
	var screen_size = get_viewport().get_visible_rect().size
	$Panel.size = Vector2(600, 580)
	$Panel.position = screen_size / 2 - $Panel.size / 2
	
	var minutes = int(time) / 60
	var seconds = int(time) % 60
	var kpm = 0.0
	if time > 0:
		kpm = kills / (time / 60.0)
	
	var vbox = $Panel/VBoxContainer
	for child in vbox.get_children():
		child.queue_free()
	
	# Başlık
	if won:
		_add_label(vbox, "🏆 KAZANDIN!", 36, Color("#FFD700"), true)
	else:
		_add_label(vbox, "☠ ÖLDÜN", 36, Color("#E74C3C"), true)
	_add_separator(vbox)
	
	# Süre
	_add_label(vbox, "⏱ Süre: %02d:%02d" % [minutes, seconds], 20, Color.WHITE)
	
	# Level
	_add_label(vbox, "⭐ Ulaşılan Level: " + str(level), 20, Color("#F1C40F"))
	
	# Öldürme
	_add_label(vbox, "💀 Öldürülen Düşman: " + str(kills), 20, Color("#E74C3C"))
	
	# Dakikada öldürme
	_add_label(vbox, "⚡ Dakikada Öldürme: " + ("%.1f" % kpm), 18, Color("#AAA"))
	
	_add_separator(vbox)
	
	# Altın
	_add_label(vbox, "💰 Kazanılan Altın: +" + str(gold), 22, Color("#F5E642"))
	
	_add_separator(vbox)
	
	# Butonlar
	var btn_row = HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 20)
	vbox.add_child(btn_row)
	
	var restart_btn = _make_button("🔄 Tekrar Oyna", Color("#1A1A2E"))
	var menu_btn = _make_button("🏠 Ana Menü", Color("#1A1A2E"))
	
	restart_btn.pressed.connect(_on_restart)
	menu_btn.pressed.connect(_on_menu)
	
	btn_row.add_child(restart_btn)
	btn_row.add_child(menu_btn)
	
	visible = true

func _add_label(parent: Node, text: String, size: int, color: Color, bold: bool = false):
	var label = Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)

func _add_separator(parent: Node):
	var sep = HSeparator.new()
	sep.add_theme_color_override("color", Color("#333355"))
	parent.add_child(sep)

func _make_button(text: String, bg_color: Color) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(220, 55)
	var style = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.add_theme_font_size_override("font_size", 18)
	return btn

func _on_restart():
	get_tree().paused = false
	ObjectPool.reset_all()
	queue_free()
	get_tree().change_scene_to_file("res://ui/character_select.tscn")

func _on_menu():
	get_tree().paused = false
	queue_free()
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")
