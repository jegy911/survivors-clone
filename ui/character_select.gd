extends CanvasLayer

var selected_index = -1

func _ready():
	build_characters()
	_update_gold_label()
	$Panel/VBoxContainer/ActionRow/BackButton.pressed.connect(_on_back)
	$Panel/VBoxContainer/ActionRow/PlayButton.pressed.connect(_on_play)
	$Panel/VBoxContainer/ActionRow/PlayButton.disabled = true

func _update_gold_label():
	if has_node("Panel/VBoxContainer/GoldLabel"):
		$Panel/VBoxContainer/GoldLabel.text = "💰 " + str(SaveManager.gold)

func build_characters():
	var container = $Panel/VBoxContainer/ScrollContainer/HBoxContainer
	for child in container.get_children():
		child.queue_free()

	for i in CharacterData.CHARACTERS.size():
		var char_data = CharacterData.CHARACTERS[i]
		var state = _get_state(char_data["id"])
		var card = _build_card(i, char_data, state)
		container.add_child(card)

func _get_state(char_id: String) -> String:
	if SaveManager.is_purchased(char_id):
		return "purchased"
	elif SaveManager.is_unlocked(char_id):
		return "unlocked"
	else:
		return "locked"

func _build_card(i: int, char_data: Dictionary, state: String) -> PanelContainer:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(200, 310)
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

	# Karakter görseli
	var char_visual = ColorRect.new()
	char_visual.custom_minimum_size = Vector2(70, 70)
	char_visual.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	# İsim etiketi
	var name_label = Label.new()
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 18)

	# Açıklama etiketi
	var desc_label = Label.new()
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.add_theme_font_size_override("font_size", 12)

	# Alt buton/hint
	var bottom = Label.new()
	bottom.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bottom.add_theme_font_size_override("font_size", 13)
	bottom.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	match state:
		"purchased":
			char_visual.color = Color(char_data["color"])
			name_label.text = char_data["name"]
			name_label.add_theme_color_override("font_color", Color(char_data["color"]))
			desc_label.text = char_data["description"]
			desc_label.add_theme_color_override("font_color", Color("#AAAAAA"))

			var btn = _make_button("Seç", Color("#3498DB"))
			var idx = i
			btn.pressed.connect(func(): _on_select(idx))
			vbox.add_child(char_visual)
			vbox.add_child(name_label)
			vbox.add_child(desc_label)
			vbox.add_child(btn)

		"unlocked":
			char_visual.color = Color(0.3, 0.3, 0.3, 1.0)
			name_label.text = char_data["name"] if not char_data["secret"] else "???"
			name_label.add_theme_color_override("font_color", Color("#888888"))
			desc_label.text = char_data["description"] if not char_data["secret"] else "???"
			desc_label.add_theme_color_override("font_color", Color("#666666"))

			var cost = char_data["cost"]
			var can_afford = SaveManager.gold >= cost
			var buy_color = Color("#27AE60") if can_afford else Color("#7F8C8D")
			var btn = _make_button("Satın Al\n💰 " + str(cost), buy_color)
			btn.disabled = not can_afford
			var cid = char_data["id"]
			btn.pressed.connect(func(): _on_purchase(cid))
			vbox.add_child(char_visual)
			vbox.add_child(name_label)
			vbox.add_child(desc_label)
			vbox.add_child(btn)

		"locked":
			char_visual.color = Color(0.1, 0.1, 0.15, 1.0)
			name_label.text = "???" if char_data["secret"] else "🔒 " + char_data["name"]
			name_label.add_theme_color_override("font_color", Color("#444466"))
			desc_label.text = ""

			bottom.text = char_data["unlock_hint"] if not char_data["secret"] else "???"
			bottom.add_theme_color_override("font_color", Color("#555577"))
			vbox.add_child(char_visual)
			vbox.add_child(name_label)
			vbox.add_child(desc_label)
			vbox.add_child(bottom)

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
	_update_selection_borders()
	$Panel/VBoxContainer/ActionRow/PlayButton.disabled = false

func _update_selection_borders():
	var container = $Panel/VBoxContainer/ScrollContainer/HBoxContainer
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

func _on_purchase(char_id: String):
	if SaveManager.purchase_character(char_id):
		build_characters()
		_update_gold_label()

func _on_play():
	if selected_index < 0:
		return
	SaveManager.selected_character = selected_index
	SaveManager.save_game()
	get_tree().change_scene_to_file("res://main/main.tscn")

func _on_back():
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")
