extends CanvasLayer

var current_tab = "ses"

func _ready():
	var screen_size = get_viewport().get_visible_rect().size
	$Background.size = screen_size
	$Background.color = Color("#0D0D1A")
	
	_build_ui()

func _build_ui():
	var vbox = $VBoxContainer
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.alignment = BoxContainer.ALIGNMENT_BEGIN
	vbox.add_theme_constant_override("separation", 0)
	
	# Başlık
	$VBoxContainer/TitleLabel.text = "AYARLAR"
	$VBoxContainer/TitleLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$VBoxContainer/TitleLabel.add_theme_font_size_override("font_size", 36)
	$VBoxContainer/TitleLabel.add_theme_color_override("font_color", Color("#9B59B6"))
	
	# Tab butonları
	_style_tab_button($VBoxContainer/TabRow/SesTab, "🔊 Ses")
	_style_tab_button($VBoxContainer/TabRow/GoruntuTab, "🖥 Görüntü")
	_style_tab_button($VBoxContainer/TabRow/OynanisTab, "🎮 Oynanış")
	
	$VBoxContainer/TabRow/SesTab.pressed.connect(func(): _switch_tab("ses"))
	$VBoxContainer/TabRow/GoruntuTab.pressed.connect(func(): _switch_tab("goruntu"))
	$VBoxContainer/TabRow/OynanisTab.pressed.connect(func(): _switch_tab("oynanis"))
	
	# Geri butonu
	_style_back_button($VBoxContainer/BackButton)
	$VBoxContainer/BackButton.pressed.connect(_on_back)
	
	_switch_tab("ses")

func _style_tab_button(btn: Button, text: String):
	btn.text = text
	btn.custom_minimum_size = Vector2(180, 50)
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#1A1A2E")
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 0
	style.corner_radius_bottom_right = 0
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.add_theme_font_size_override("font_size", 16)

func _style_back_button(btn: Button):
	btn.text = "← Ana Menü"
	btn.custom_minimum_size = Vector2(200, 50)
	btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#1A1A2E")
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_color_override("font_color", Color.WHITE)

func _switch_tab(tab: String):
	current_tab = tab
	var content = $VBoxContainer/ContentArea
	for child in content.get_children():
		child.queue_free()
	
	match tab:
		"ses": _build_ses_tab(content)
		"goruntu": _build_goruntu_tab(content)
		"oynanis": _build_oynanis_tab(content)
	
	# Aktif tab rengi
	var tabs = {
		"ses": $VBoxContainer/TabRow/SesTab,
		"goruntu": $VBoxContainer/TabRow/GoruntuTab,
		"oynanis": $VBoxContainer/TabRow/OynanisTab,
	}
	for t in tabs:
		var style = StyleBoxFlat.new()
		style.bg_color = Color("#9B59B6") if t == tab else Color("#1A1A2E")
		style.corner_radius_top_left = 8
		style.corner_radius_top_right = 8
		tabs[t].add_theme_stylebox_override("normal", style)

func _build_ses_tab(parent: Node):
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	parent.add_child(vbox)
	
	var settings = SaveManager.settings
	
	_add_slider(vbox, "Genel Ses", settings.get("master_volume", 1.0), func(val):
		SaveManager.settings["master_volume"] = val
		AudioServer.set_bus_volume_db(0, linear_to_db(val))
		SaveManager.save_game()
	)
	
	_add_slider(vbox, "Efekt Sesi", settings.get("sfx_volume", 1.0), func(val):
		SaveManager.settings["sfx_volume"] = val
		var bus = AudioServer.get_bus_index("SFX")
		if bus >= 0:
			AudioServer.set_bus_volume_db(bus, linear_to_db(val))
		SaveManager.save_game()
	)
	
	_add_slider(vbox, "Müzik", settings.get("music_volume", 1.0), func(val):
		SaveManager.settings["music_volume"] = val
		var bus = AudioServer.get_bus_index("Music")
		if bus >= 0:
			AudioServer.set_bus_volume_db(bus, linear_to_db(val))
		SaveManager.save_game()
	)

func _build_goruntu_tab(parent: Node):
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	parent.add_child(vbox)
	
	_add_toggle(vbox, "Tam Ekran", SaveManager.settings.get("fullscreen", false), func(val):
		SaveManager.settings["fullscreen"] = val
		if val:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		SaveManager.save_game()
	)
	
	_add_toggle(vbox, "VFX Efektleri", SaveManager.settings.get("vfx_enabled", true), func(val):
		SaveManager.settings["vfx_enabled"] = val
		SaveManager.save_game()
	)

func _build_oynanis_tab(parent: Node):
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	parent.add_child(vbox)
	
	_add_toggle(vbox, "Hasar Sayıları", SaveManager.settings.get("damage_numbers", true), func(val):
		SaveManager.settings["damage_numbers"] = val
		SaveManager.save_game()
	)
	
	_add_toggle(vbox, "Ekran Sarsıntısı", SaveManager.settings.get("screen_shake", true), func(val):
		SaveManager.settings["screen_shake"] = val
		SaveManager.save_game()
	)

func _add_slider(parent: Node, label_text: String, default_val: float, callback: Callable):
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 20)
	parent.add_child(row)
	
	var label = Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(200, 0)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_font_size_override("font_size", 18)
	row.add_child(label)
	
	var slider = HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = default_val
	slider.custom_minimum_size = Vector2(300, 40)
	slider.value_changed.connect(callback)
	row.add_child(slider)
	
	var percent = Label.new()
	percent.text = str(int(default_val * 100)) + "%"
	percent.custom_minimum_size = Vector2(60, 0)
	percent.add_theme_color_override("font_color", Color("#AAAAAA"))
	row.add_child(percent)
	
	slider.value_changed.connect(func(val):
		percent.text = str(int(val * 100)) + "%"
	)

func _add_toggle(parent: Node, label_text: String, default_val: bool, callback: Callable):
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 20)
	parent.add_child(row)
	
	var label = Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(200, 0)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_font_size_override("font_size", 18)
	row.add_child(label)
	
	var btn = CheckButton.new()
	btn.button_pressed = default_val
	btn.toggled.connect(callback)
	row.add_child(btn)

func _on_back():
	var from_game = get_meta("from_game", false)
	if from_game:
		get_tree().paused = true
		var pause_menu = preload("res://ui/pause_menu.tscn").instantiate()
		pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS
		get_tree().root.add_child(pause_menu)
		queue_free()
	else:
		get_tree().change_scene_to_file("res://ui/main_menu.tscn")
