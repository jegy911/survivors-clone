extends CanvasLayer

func _ready():
	var screen_size = get_viewport().get_visible_rect().size
	
	$Background.size = screen_size
	$Background.color = Color("#0A0A14")
	
	$VBoxContainer.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	$VBoxContainer.alignment = BoxContainer.ALIGNMENT_CENTER
	$VBoxContainer.size = Vector2(420, 560)
	$VBoxContainer.position = screen_size / 2 - $VBoxContainer.size / 2
	$VBoxContainer.add_theme_constant_override("separation", 18)
	
	$VBoxContainer/TitleLabel.text = "SURVIVORS"
	$VBoxContainer/TitleLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$VBoxContainer/TitleLabel.add_theme_font_size_override("font_size", 52)
	$VBoxContainer/TitleLabel.add_theme_color_override("font_color", Color("#9B59B6"))
	
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property($VBoxContainer/TitleLabel, "modulate:a", 1.0, 1.2)
	tween.tween_property($VBoxContainer/TitleLabel, "modulate:a", 0.75, 1.2)
	
	$VBoxContainer/GoldLabel.text = "💰 " + str(SaveManager.gold)
	$VBoxContainer/GoldLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$VBoxContainer/GoldLabel.add_theme_color_override("font_color", Color("#FFD700"))
	$VBoxContainer/GoldLabel.add_theme_font_size_override("font_size", 22)
	
	if not AudioManager.music_player.playing:
		AudioManager.play_music(1)
	
	for btn in [$VBoxContainer/StartButton, $VBoxContainer/UpgradeButton, $VBoxContainer/SettingsButton, $VBoxContainer/QuitButton]:
		btn.custom_minimum_size = Vector2(320, 56)
		var style = StyleBoxFlat.new()
		style.bg_color = Color("#15152A")
		style.border_color = Color("#333355")
		style.border_width_left = 2
		style.border_width_right = 2
		style.border_width_top = 2
		style.border_width_bottom = 2
		style.corner_radius_top_left = 10
		style.corner_radius_top_right = 10
		style.corner_radius_bottom_left = 10
		style.corner_radius_bottom_right = 10
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_color_override("font_color", Color.WHITE)
		btn.add_theme_font_size_override("font_size", 20)
	
	$VBoxContainer/StartButton.text = "▶  OYNA"
	$VBoxContainer/UpgradeButton.text = "⬆  UPGRADES"
	$VBoxContainer/SettingsButton.text = "⚙  AYARLAR"
	$VBoxContainer/QuitButton.text = "✕  ÇIKIŞ"
	
	$VBoxContainer/StartButton.pressed.connect(_on_start)
	$VBoxContainer/UpgradeButton.pressed.connect(_on_upgrades)
	$VBoxContainer/SettingsButton.pressed.connect(_on_settings)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit)

func _on_start():
	get_tree().change_scene_to_file("res://ui/character_select.tscn")

func _on_upgrades():
	get_tree().change_scene_to_file("res://ui/meta_upgrade.tscn")

func _on_settings():
	get_tree().change_scene_to_file("res://ui/settings.tscn")

func _on_quit():
	get_tree().quit()
	var _easter_buffer = ""

func _input(event):
	if event is InputEventKey and event.pressed:
		var ch = OS.get_keycode_string(event.keycode).to_upper()
		if ch.length() == 1:
			_easter_buffer += ch
			if _easter_buffer.length() > 5:
				_easter_buffer = _easter_buffer.right(5)
			if _easter_buffer == "OMEGA":
				_try_unlock_omega()
				_easter_buffer = ""

func _try_unlock_omega():
	if SaveManager.unlocked_characters.has("omega"):
		return
	SaveManager.unlocked_characters.append("omega")
	SaveManager.save_game()
	var label = Label.new()
	label.text = "????? UNLOCKED"
	label.add_theme_color_override("font_color", Color("#FF0000"))
	label.add_theme_font_size_override("font_size", 28)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	$VBoxContainer.add_child(label)
	var tween = create_tween()
	tween.tween_property(label, "modulate:a", 0.0, 2.5)
	tween.tween_callback(label.queue_free)
