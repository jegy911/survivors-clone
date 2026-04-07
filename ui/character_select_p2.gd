extends CanvasLayer

var selected_index = -1

func _ready():
	var vp = get_viewport().get_visible_rect().size
	$Panel/VBoxContainer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	$Panel/VBoxContainer.add_theme_constant_override("separation", 16)
	$Panel/VBoxContainer/TitleLabel.add_theme_font_size_override("font_size", 32)
	$Panel/VBoxContainer/TitleLabel.add_theme_color_override("font_color", Color("#2471A3"))
	$Panel/VBoxContainer/TitleLabel.text = tr("ui.character_select.p2_title")
	$Panel/VBoxContainer/ScrollContainer/GridContainer.add_theme_constant_override("h_separation", 16)
	$Panel/VBoxContainer/ScrollContainer/GridContainer.add_theme_constant_override("v_separation", 16)
	build_characters()
	$Panel/VBoxContainer/ActionRow/BackButton.pressed.connect(_on_back)
	$Panel/VBoxContainer/ActionRow/PlayButton.pressed.connect(_on_play)
	$Panel/VBoxContainer/ActionRow/PlayButton.disabled = true

func build_characters():
	var container = $Panel/VBoxContainer/ScrollContainer/GridContainer
	for child in container.get_children():
		child.queue_free()
	for i in CharacterData.CHARACTERS.size():
		var char_data = CharacterData.CHARACTERS[i]
		# P1'in seçtiği karakteri engelle
		var is_taken = (i == SaveManager.selected_character)
		var card = _build_card(i, char_data, is_taken)
		container.add_child(card)

func _build_card(i: int, char_data: Dictionary, is_taken: bool) -> PanelContainer:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(180, 280)
	card.set_meta("index", i)
	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color("#1A1A2E")
	card_style.corner_radius_top_left = 12
	card_style.corner_radius_top_right = 12
	card_style.corner_radius_bottom_left = 12
	card_style.corner_radius_bottom_right = 12
	card_style.border_width_left = 2
	card_style.border_width_right = 2
	card_style.border_width_top = 2
	card_style.border_width_bottom = 2
	card_style.border_color = Color("#333355")
	card.add_theme_stylebox_override("panel", card_style)

	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 8)

	var char_visual = ColorRect.new()
	char_visual.custom_minimum_size = Vector2(70, 70)
	char_visual.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	var name_label = Label.new()
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 18)

	var desc_label = Label.new()
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.add_theme_font_size_override("font_size", 12)

	if is_taken:
		# P1 tarafından seçildi
		char_visual.color = Color(0.1, 0.1, 0.15, 1.0)
		name_label.text = char_data["name"]
		name_label.add_theme_color_override("font_color", Color("#444466"))
		desc_label.text = tr("ui.character_select.taken_by_p1")
		desc_label.add_theme_color_override("font_color", Color("#444466"))
		var taken_label = Label.new()
		taken_label.text = tr("ui.character_select.locked_p1")
		taken_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		taken_label.add_theme_color_override("font_color", Color("#922B21"))
		vbox.add_child(char_visual)
		vbox.add_child(name_label)
		vbox.add_child(desc_label)
		vbox.add_child(taken_label)
	else:
		char_visual.color = Color(char_data["color"])
		name_label.text = char_data["name"]
		name_label.add_theme_color_override("font_color", Color(char_data["color"]))
		desc_label.text = CharacterSelectHelpers.rich_description_unlocked(char_data)
		desc_label.add_theme_color_override("font_color", Color("#B0B0B0"))
		var btn: Button
		if i == selected_index:
			btn = _make_button("✅ Hazır!", Color("#27AE60"))
			$Panel/VBoxContainer/ActionRow/PlayButton.disabled = false
		else:
			btn = _make_button("Seç", Color("#2471A3"))
		var idx = i
		btn.pressed.connect(func(): _on_select(idx))
		vbox.add_child(char_visual)
		vbox.add_child(name_label)
		vbox.add_child(desc_label)
		vbox.add_child(btn)

	card.add_child(vbox)
	return card

func _make_button(label_text: String, color: Color) -> Button:
	var btn = Button.new()
	btn.text = label_text
	btn.custom_minimum_size = Vector2(140, 50)
	var style = StyleBoxFlat.new()
	style.bg_color = color.darkened(0.3)
	style.border_color = color
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
	btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	return btn

func _on_select(index: int):
	selected_index = index
	build_characters()

func _update_selection_borders():
	var container = $Panel/VBoxContainer/ScrollContainer/GridContainer
	for i in container.get_child_count():
		var card = container.get_child(i)
		var style = card.get_theme_stylebox("panel").duplicate()
		if i == selected_index:
			var char_data = CharacterData.CHARACTERS[i]
			style.border_color = Color(char_data["color"])
			style.border_width_left = 3
			style.border_width_right = 3
			style.border_width_top = 3
			style.border_width_bottom = 3
		else:
			style.border_color = Color("#333355")
			style.border_width_left = 2
			style.border_width_right = 2
			style.border_width_top = 2
			style.border_width_bottom = 2
		card.add_theme_stylebox_override("panel", style)

func _on_back():
	get_tree().change_scene_to_file("res://ui/character_select.tscn")

func _on_play():
	if selected_index < 0:
		return
	SaveManager.selected_character_p2 = selected_index
	SaveManager.save_game()
	get_tree().change_scene_to_file("res://ui/map_select.tscn")
