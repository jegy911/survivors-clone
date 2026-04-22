extends CanvasLayer

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
	title.text = tr("ui.game_mode.title")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color("#9B59B6"))
	vbox.add_child(title)

	vbox.add_child(HSeparator.new())

	var btn_row = HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 20)
	vbox.add_child(btn_row)

	var solo_btn = _make_btn(
		tr("ui.game_mode.solo"),
		Color("#27AE60"), 0)
	var local_btn = _make_btn(
		tr("ui.game_mode.local_coop"),
		Color("#2471A3"), 1)
	var online_btn = _make_btn(
		tr("ui.game_mode.online"),
		Color("#6C3483"), 2)
	online_btn.disabled = true
	online_btn.modulate.a = 0.4

	solo_btn.pressed.connect(func(): _on_mode("solo"))
	local_btn.pressed.connect(func(): _on_mode("local_coop"))

	btn_row.add_child(solo_btn)
	btn_row.add_child(local_btn)
	btn_row.add_child(online_btn)

	vbox.add_child(HSeparator.new())

	var back_btn = _make_action_btn(tr("ui.game_mode.back"))
	back_btn.pressed.connect(_on_back)
	vbox.add_child(back_btn)

	# Karakter seçim ekranı açılmadan portre dokularını arka planda önbelleğe al (takılmayı azaltır)
	call_deferred("_warmup_character_portraits")

func _warmup_character_portraits() -> void:
	await CharacterSelectPreview.warmup_portraits_async(get_tree(), 3)

func _make_btn(text: String, color: Color, cover_variant: int) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(160, 130)
	btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var tint := Color.WHITE.lerp(color, 0.24)
	ButtonCoverStyles.apply(btn, cover_variant, 15, Vector4(16.0, 10.0, 16.0, 10.0), tint)
	return btn

func _make_action_btn(text: String) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(200, 52)
	ButtonCoverStyles.apply(btn, 0, 16, Vector4(20.0, 8.0, 20.0, 8.0))
	return btn

func _on_mode(mode: String):
	SaveManager.game_mode = mode
	get_tree().change_scene_to_file("res://ui/character_select.tscn")

func _on_back():
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")


func _unhandled_input(event: InputEvent) -> void:
	if MenuInput.is_menu_back_pressed(event):
		get_viewport().set_input_as_handled()
		_on_back()
