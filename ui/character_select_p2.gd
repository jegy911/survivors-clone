extends CanvasLayer

var selected_index = -1
var _active_hero_class: String = ""
var _class_filter_buttons: Dictionary = {}
var _filter_accent: Color = Color("#2471A3")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		get_tree().change_scene_to_file("res://ui/character_select.tscn")

func _ready():
	var vp = get_viewport().get_visible_rect().size
	$Panel/VBoxContainer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	$Panel/VBoxContainer.add_theme_constant_override("separation", 16)
	$Panel/VBoxContainer/TitleLabel.add_theme_font_size_override("font_size", 32)
	$Panel/VBoxContainer/TitleLabel.add_theme_color_override("font_color", Color("#2471A3"))
	$Panel/VBoxContainer/TitleLabel.text = tr("ui.character_select.p2_title")
	$Panel/VBoxContainer/ScrollContainer/GridContainer.add_theme_constant_override("h_separation", 16)
	$Panel/VBoxContainer/ScrollContainer/GridContainer.add_theme_constant_override("v_separation", 16)
	_setup_class_filter_row()
	build_characters()
	$Panel/VBoxContainer/ActionRow/BackButton.pressed.connect(_on_back)
	$Panel/VBoxContainer/ActionRow/PlayButton.pressed.connect(_on_play)
	$Panel/VBoxContainer/ActionRow/PlayButton.disabled = true

func _setup_class_filter_row():
	var vbox: VBoxContainer = $Panel/VBoxContainer
	if vbox.get_node_or_null("ClassFilterRow"):
		return
	var row = HBoxContainer.new()
	row.name = "ClassFilterRow"
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 10)
	var gold = vbox.get_node_or_null("GoldLabel")
	var insert_at = gold.get_index() + 1 if gold else 1
	vbox.add_child(row)
	vbox.move_child(row, insert_at)
	_class_filter_buttons.clear()
	for class_id in CharacterData.HERO_CLASS_FILTER_IDS:
		var btn = Button.new()
		btn.text = tr("ui.character_select.filter_%s" % class_id)
		btn.custom_minimum_size = Vector2(104, 36)
		var cid: String = class_id
		btn.pressed.connect(func(): _on_class_filter_pressed(cid))
		row.add_child(btn)
		_class_filter_buttons[cid] = btn
	_refresh_class_filter_buttons()

func _style_class_filter_button(btn: Button, active: bool) -> void:
	var style = StyleBoxFlat.new()
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	if active:
		style.bg_color = _filter_accent.darkened(0.45)
		style.border_color = _filter_accent
	else:
		style.bg_color = Color("#252538")
		style.border_color = Color("#444466")
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_color_override("font_color", Color.WHITE)

func _refresh_class_filter_buttons() -> void:
	for class_id in _class_filter_buttons:
		var btn: Button = _class_filter_buttons[class_id]
		_style_class_filter_button(btn, class_id == _active_hero_class)

func _on_class_filter_pressed(class_id: String) -> void:
	if _active_hero_class == class_id:
		_active_hero_class = ""
	else:
		_active_hero_class = class_id
	_refresh_class_filter_buttons()
	if selected_index >= 0:
		var cd: Dictionary = CharacterData.CHARACTERS[selected_index]
		if _active_hero_class != "" and str(cd.get("hero_class", "")) != _active_hero_class:
			selected_index = -1
			$Panel/VBoxContainer/ActionRow/PlayButton.disabled = true
	build_characters()

func _character_visible_for_filter(char_index: int, char_data: Dictionary) -> bool:
	if char_index == SaveManager.selected_character:
		return true
	if _active_hero_class.is_empty():
		return true
	return str(char_data.get("hero_class", "")) == _active_hero_class

func build_characters():
	var container = $Panel/VBoxContainer/ScrollContainer/GridContainer
	for child in container.get_children():
		child.queue_free()
	for i in CharacterData.CHARACTERS.size():
		var char_data = CharacterData.CHARACTERS[i]
		if not _character_visible_for_filter(i, char_data):
			continue
		# P1'in seçtiği karakteri engelle
		var is_taken = (i == SaveManager.selected_character)
		var card = _build_card(i, char_data, is_taken)
		container.add_child(card)

func _build_card(i: int, char_data: Dictionary, is_taken: bool) -> PanelContainer:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(188, 340)
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

	var cid: String = str(char_data["id"])
	var char_visual: Control

	var name_label = Label.new()
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 18)

	var desc_label = Label.new()
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.add_theme_font_size_override("font_size", 12)

	if is_taken:
		char_visual = CharacterSelectPreview.make_portrait(cid, "taken", Color(char_data["color"]))
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
		char_visual = CharacterSelectPreview.make_portrait(cid, "full", Color(char_data["color"]))
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
	for vis_i in container.get_child_count():
		var card = container.get_child(vis_i)
		var char_idx: int = int(card.get_meta("index"))
		var style = card.get_theme_stylebox("panel").duplicate()
		if char_idx == selected_index:
			var char_data = CharacterData.CHARACTERS[char_idx]
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
