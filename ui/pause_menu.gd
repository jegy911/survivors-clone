extends CanvasLayer

const SETTINGS_SCENE := preload("res://ui/settings.tscn")


func _ready():
	add_to_group("pause_menu_overlay")
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

	var pause_btns: Array[Button] = [
		$VBoxContainer/ResumeButton,
		$VBoxContainer/SettingsButton,
		$VBoxContainer/MainMenuButton,
	]
	var cover_i := 0
	for btn in pause_btns:
		btn.custom_minimum_size = Vector2(300, 60)
		ButtonCoverStyles.apply(btn, cover_i % 3, 20, Vector4(28.0, 8.0, 28.0, 8.0))
		cover_i += 1

	$VBoxContainer/ResumeButton.text = tr("ui.pause.resume")
	$VBoxContainer/SettingsButton.text = tr("ui.pause.settings")
	$VBoxContainer/MainMenuButton.text = tr("ui.pause.main_menu")

	$VBoxContainer/ResumeButton.pressed.connect(_on_resume)
	$VBoxContainer/SettingsButton.pressed.connect(_on_settings)
	$VBoxContainer/MainMenuButton.pressed.connect(_on_main_menu)


func restore_after_settings() -> void:
	$VBoxContainer.visible = true
	$Background.visible = true


func _unhandled_input(event: InputEvent) -> void:
	if not MenuInput.is_menu_back_pressed(event):
		return
	get_viewport().set_input_as_handled()
	var overlay: Node = get_tree().get_first_node_in_group("settings_overlay_from_pause")
	if overlay != null and is_instance_valid(overlay):
		AudioManager.apply_volume_settings()
		overlay.queue_free()
		restore_after_settings()
		return
	_on_resume()


func _on_resume():
	get_tree().paused = false
	queue_free()


func _on_settings():
	$VBoxContainer.visible = false
	$Background.visible = false
	var settings_ui: CanvasLayer = SETTINGS_SCENE.instantiate()
	settings_ui.set_meta("from_game", true)
	settings_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	settings_ui.layer = 30
	settings_ui.add_to_group("settings_overlay_from_pause")
	get_tree().root.add_child(settings_ui)


func _on_main_menu():
	get_tree().paused = false
	queue_free()
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")
