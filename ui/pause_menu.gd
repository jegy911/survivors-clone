extends CanvasLayer

func _ready():
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	var screen_size = get_viewport().get_visible_rect().size

	$Background.size = screen_size
	$Background.color = Color(0, 0, 0, 0.6)

	$VBoxContainer.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	$VBoxContainer.alignment = BoxContainer.ALIGNMENT_CENTER
	$VBoxContainer.size = Vector2(350, 400)
	$VBoxContainer.position = screen_size / 2 - $VBoxContainer.size / 2
	$VBoxContainer.add_theme_constant_override("separation", 16)

	$VBoxContainer/TitleLabel.text = tr("ui.pause.title")
	$VBoxContainer/TitleLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$VBoxContainer/TitleLabel.add_theme_font_size_override("font_size", 42)
	$VBoxContainer/TitleLabel.add_theme_color_override("font_color", Color.WHITE)

	for btn in [$VBoxContainer/ResumeButton, $VBoxContainer/SettingsButton, $VBoxContainer/MainMenuButton]:
		btn.custom_minimum_size = Vector2(300, 60)
		var style = StyleBoxFlat.new()
		style.bg_color = Color("#1A1A2E")
		style.corner_radius_top_left = 8
		style.corner_radius_top_right = 8
		style.corner_radius_bottom_left = 8
		style.corner_radius_bottom_right = 8
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_color_override("font_color", Color.WHITE)
		btn.add_theme_font_size_override("font_size", 20)

	$VBoxContainer/ResumeButton.text = tr("ui.pause.resume")
	$VBoxContainer/SettingsButton.text = tr("ui.pause.settings")
	$VBoxContainer/MainMenuButton.text = tr("ui.pause.main_menu")

	$VBoxContainer/ResumeButton.pressed.connect(_on_resume)
	$VBoxContainer/SettingsButton.pressed.connect(_on_settings)
	$VBoxContainer/MainMenuButton.pressed.connect(_on_main_menu)

func _on_resume():
	get_tree().paused = false
	queue_free()

func _on_settings():
	$VBoxContainer.visible = false
	$Background.visible = false
	var settings_panel = _build_settings_panel()
	settings_panel.z_index = 100
	add_child(settings_panel)

func _build_settings_panel() -> Control:
	var screen_size = get_viewport().get_visible_rect().size
	var bg = ColorRect.new()
	bg.size = screen_size
	bg.color = Color("#0D0D1A")
	bg.name = "SettingsPanel"
	bg.z_index = 100

	var vbox = VBoxContainer.new()
	vbox.size = Vector2(600, 500)
	vbox.position = screen_size / 2 - Vector2(300, 250)
	vbox.alignment = BoxContainer.ALIGNMENT_BEGIN
	vbox.add_theme_constant_override("separation", 24)
	bg.add_child(vbox)

	var title = Label.new()
	title.text = tr("ui.pause.settings_title")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color("#9B59B6"))
	vbox.add_child(title)

	_add_slider_to(vbox, tr("ui.settings.master"), SaveManager.settings.get("master_volume", 1.0), func(val):
		SaveManager.settings["master_volume"] = val
		AudioServer.set_bus_volume_db(0, linear_to_db(val))
		SaveManager.save_game()
	)
	_add_slider_to(vbox, tr("ui.settings.sfx"), SaveManager.settings.get("sfx_volume", 1.0), func(val):
		SaveManager.settings["sfx_volume"] = val
		var bus = AudioServer.get_bus_index("SFX")
		if bus >= 0:
			AudioServer.set_bus_volume_db(bus, linear_to_db(val))
		SaveManager.save_game()
	)
	_add_slider_to(vbox, tr("ui.settings.music"), SaveManager.settings.get("music_volume", 1.0), func(val):
		SaveManager.settings["music_volume"] = val
		var bus = AudioServer.get_bus_index("Music")
		if bus >= 0:
			AudioServer.set_bus_volume_db(bus, linear_to_db(val))
		SaveManager.save_game()
	)

	_add_toggle_to(vbox, tr("ui.settings.vfx"), SaveManager.settings.get("show_vfx", true), func(val):
		SaveManager.settings["show_vfx"] = val
		SaveManager.save_game()
	)

	_add_toggle_to(vbox, tr("ui.settings.screen_shake"), SaveManager.settings.get("screen_shake", true), func(val):
		SaveManager.settings["screen_shake"] = val
		SaveManager.save_game()
	)

	_add_dropdown_to(vbox, tr("ui.settings.damage_numbers"), SaveManager.settings.get("damage_numbers", "both_on"), func(val):
		SaveManager.settings["damage_numbers"] = val
		SaveManager.save_game()
	)

	_add_dropdown_to(vbox, tr("ui.settings.hp_bars"), SaveManager.settings.get("hp_bars", "both_on"), func(val):
		SaveManager.settings["hp_bars"] = val
		SaveManager.save_game()
	)

	var back_btn = Button.new()
	back_btn.text = tr("ui.pause.back")
	back_btn.custom_minimum_size = Vector2(200, 50)
	back_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var back_style = StyleBoxFlat.new()
	back_style.bg_color = Color("#1A1A2E")
	back_style.corner_radius_top_left = 8
	back_style.corner_radius_top_right = 8
	back_style.corner_radius_bottom_left = 8
	back_style.corner_radius_bottom_right = 8
	back_btn.add_theme_stylebox_override("normal", back_style)
	back_btn.add_theme_color_override("font_color", Color.WHITE)
	back_btn.pressed.connect(func():
		bg.queue_free()
		$VBoxContainer.visible = true
		$Background.visible = true
	)
	vbox.add_child(back_btn)
	return bg

func _add_slider_to(parent: Node, label_text: String, default_val: float, callback: Callable):
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

func _add_toggle_to(parent: Node, label_text: String, default_val: bool, callback: Callable):
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

func _add_dropdown_to(parent: Node, label_text: String, current_val: String, callback: Callable):
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 20)
	parent.add_child(row)
	var label = Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(200, 0)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_font_size_override("font_size", 18)
	row.add_child(label)
	var options = ["both_on", "player_only", "enemy_only", "both_off"]
	var option_keys = ["option_both_on", "option_player_only", "option_enemy_only", "option_both_off"]
	var dropdown = OptionButton.new()
	dropdown.custom_minimum_size = Vector2(220, 40)
	for i in options.size():
		dropdown.add_item(tr("ui.settings." + option_keys[i]))
	dropdown.selected = options.find(current_val)
	dropdown.item_selected.connect(func(idx): callback.call(options[idx]))
	row.add_child(dropdown)

func _on_main_menu():
	get_tree().paused = false
	queue_free()
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")
