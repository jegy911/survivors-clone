extends CanvasLayer

func _ready():
	if not LocalizationManager.locale_changed.is_connected(_refresh_ui):
		LocalizationManager.locale_changed.connect(_refresh_ui)
	_build_ui()

func _refresh_ui(_locale: String = "") -> void:
	_apply_texts()

func _apply_texts():
	var screen_size = get_viewport().get_visible_rect().size

	$VBoxContainer/TitleLabel.text = tr("ui.main_menu.title")

	var subtitle = $VBoxContainer.get_node_or_null("SubtitleLabel")
	if subtitle:
		subtitle.text = tr("ui.main_menu.subtitle")

	var stats_label = $VBoxContainer.get_node_or_null("StatsLabel")
	if stats_label:
		var wins = SaveManager.total_wins
		var runs = SaveManager.total_runs
		var kills = SaveManager.total_kills
		stats_label.text = tr("ui.main_menu.stats") % [runs, kills, wins]

	$VBoxContainer/GoldLabel.text = tr("ui.main_menu.gold") % SaveManager.gold

	var button_configs = [
		[$VBoxContainer/StartButton, tr("ui.main_menu.play"), Color("#27AE60"), Color("#1E8449")],
		[$VBoxContainer/UpgradeButton, tr("ui.main_menu.meta"), Color("#8E44AD"), Color("#6C3483")],
		[$VBoxContainer/CollectionButton, tr("ui.main_menu.collection"), Color("#D68910"), Color("#B7950B")],
		[$VBoxContainer/SettingsButton, tr("ui.main_menu.settings"), Color("#2471A3"), Color("#1A5276")],
		[$VBoxContainer/QuitButton, tr("ui.main_menu.quit"), Color("#922B21"), Color("#7B241C")],
	]

	for config in button_configs:
		var btn = config[0]
		btn.text = config[1]
		var style = StyleBoxFlat.new()
		style.bg_color = config[3]
		style.border_color = config[2]
		style.border_width_left = 2
		style.border_width_right = 2
		style.border_width_top = 2
		style.border_width_bottom = 2
		style.corner_radius_top_left = 10
		style.corner_radius_top_right = 10
		style.corner_radius_bottom_left = 10
		style.corner_radius_bottom_right = 10
		btn.add_theme_stylebox_override("normal", style)
		var hover_style = style.duplicate()
		hover_style.bg_color = config[2]
		btn.add_theme_stylebox_override("hover", hover_style)

func _build_ui():
	var screen_size = get_viewport().get_visible_rect().size

	$Background.size = screen_size
	$Background.color = Color("#0A0A14")

	for c in $Background.get_children():
		c.queue_free()

	for i in 40:
		var star = ColorRect.new()
		star.size = Vector2(randf_range(1, 3), randf_range(1, 3))
		star.color = Color(1, 1, 1, randf_range(0.2, 0.8))
		star.position = Vector2(randf_range(0, screen_size.x), randf_range(0, screen_size.y))
		$Background.add_child(star)
		var st = star.create_tween()
		st.set_loops()
		st.tween_property(star, "modulate:a", 0.1, randf_range(1.0, 3.0))
		st.tween_property(star, "modulate:a", 1.0, randf_range(1.0, 3.0))

	$VBoxContainer.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	$VBoxContainer.alignment = BoxContainer.ALIGNMENT_CENTER
	$VBoxContainer.size = Vector2(420, 660)
	$VBoxContainer.position = screen_size / 2 - $VBoxContainer.size / 2
	$VBoxContainer.add_theme_constant_override("separation", 14)

	$VBoxContainer/TitleLabel.text = tr("ui.main_menu.title")
	$VBoxContainer/TitleLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$VBoxContainer/TitleLabel.add_theme_font_size_override("font_size", 48)
	$VBoxContainer/TitleLabel.add_theme_color_override("font_color", Color("#9B59B6"))

	var tween = create_tween()
	tween.set_loops()
	tween.tween_property($VBoxContainer/TitleLabel, "modulate", Color(1.0, 0.8, 1.0, 1.0), 1.5)
	tween.tween_property($VBoxContainer/TitleLabel, "modulate", Color(0.7, 0.5, 1.0, 0.8), 1.5)

	var subtitle = Label.new()
	subtitle.name = "SubtitleLabel"
	subtitle.text = tr("ui.main_menu.subtitle")
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_color_override("font_color", Color("#666688"))
	subtitle.add_theme_font_size_override("font_size", 14)
	$VBoxContainer.add_child(subtitle)
	$VBoxContainer.move_child(subtitle, 1)

	var stats_label = Label.new()
	stats_label.name = "StatsLabel"
	var wins = SaveManager.total_wins
	var runs = SaveManager.total_runs
	var kills = SaveManager.total_kills
	stats_label.text = tr("ui.main_menu.stats") % [runs, kills, wins]
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_label.add_theme_color_override("font_color", Color("#555577"))
	stats_label.add_theme_font_size_override("font_size", 12)
	$VBoxContainer.add_child(stats_label)
	$VBoxContainer.move_child(stats_label, 2)

	$VBoxContainer/GoldLabel.text = tr("ui.main_menu.gold") % SaveManager.gold
	$VBoxContainer/GoldLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$VBoxContainer/GoldLabel.add_theme_color_override("font_color", Color("#FFD700"))
	$VBoxContainer/GoldLabel.add_theme_font_size_override("font_size", 20)

	if not AudioManager.music_player.playing:
		AudioManager.play_music(1)

	var button_configs = [
		[$VBoxContainer/StartButton, tr("ui.main_menu.play"), Color("#27AE60"), Color("#1E8449")],
		[$VBoxContainer/UpgradeButton, tr("ui.main_menu.meta"), Color("#8E44AD"), Color("#6C3483")],
		[$VBoxContainer/CollectionButton, tr("ui.main_menu.collection"), Color("#D68910"), Color("#B7950B")],
		[$VBoxContainer/SettingsButton, tr("ui.main_menu.settings"), Color("#2471A3"), Color("#1A5276")],
		[$VBoxContainer/QuitButton, tr("ui.main_menu.quit"), Color("#922B21"), Color("#7B241C")],
	]

	for config in button_configs:
		var btn = config[0]
		btn.text = config[1]
		btn.custom_minimum_size = Vector2(340, 60)
		var style = StyleBoxFlat.new()
		style.bg_color = config[3]
		style.border_color = config[2]
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
		var hover_style = style.duplicate()
		hover_style.bg_color = config[2]
		btn.add_theme_stylebox_override("hover", hover_style)

	$VBoxContainer/StartButton.pressed.connect(_on_start)
	$VBoxContainer/UpgradeButton.pressed.connect(_on_upgrades)
	$VBoxContainer/CollectionButton.pressed.connect(_on_collection)
	$VBoxContainer/SettingsButton.pressed.connect(_on_settings)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit)

func _on_start():
	get_tree().change_scene_to_file("res://ui/game_mode_select.tscn")

func _on_upgrades():
	get_tree().change_scene_to_file("res://ui/meta_upgrade.tscn")

func _on_collection():
	get_tree().change_scene_to_file("res://ui/collection_menu.tscn")

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
	label.text = tr("ui.main_menu.omega_unlock")
	label.add_theme_color_override("font_color", Color("#FF0000"))
	label.add_theme_font_size_override("font_size", 28)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	$VBoxContainer.add_child(label)
	var tween = create_tween()
	tween.tween_property(label, "modulate:a", 0.0, 2.5)
	tween.tween_callback(label.queue_free)
