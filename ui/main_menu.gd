extends CanvasLayer

func _ready():
	var screen_size = get_viewport().get_visible_rect().size
	
	$Background.size = screen_size
	$Background.color = Color("#0D0D1A")
	
	$VBoxContainer.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	$VBoxContainer.alignment = BoxContainer.ALIGNMENT_CENTER
	$VBoxContainer.size = Vector2(400, 500)
	$VBoxContainer.position = screen_size / 2 - $VBoxContainer.size / 2
	
	$VBoxContainer/TitleLabel.text = "SURVIVORS"
	$VBoxContainer/TitleLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$VBoxContainer/TitleLabel.add_theme_font_size_override("font_size", 48)
	$VBoxContainer/TitleLabel.add_theme_color_override("font_color", Color("#9B59B6"))
	
	$VBoxContainer/GoldLabel.text = "💰 Altın: " + str(SaveManager.gold)
	$VBoxContainer/GoldLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$VBoxContainer/GoldLabel.add_theme_color_override("font_color", Color("#F5E642"))
	$VBoxContainer/GoldLabel.add_theme_font_size_override("font_size", 20)
	
	if not AudioManager.music_player.playing:
		AudioManager.play_music(1)
	
	for btn in [$VBoxContainer/StartButton, $VBoxContainer/UpgradeButton, $VBoxContainer/SettingsButton, $VBoxContainer/QuitButton]:
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
	
	$VBoxContainer/StartButton.text = "OYNA"
	$VBoxContainer/UpgradeButton.text = "UPGRADES"
	$VBoxContainer/SettingsButton.text = "AYARLAR"
	$VBoxContainer/QuitButton.text = "ÇIKIŞ"
	
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
