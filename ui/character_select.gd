extends CanvasLayer

var selected_index = -1

func _ready():
	var vp = get_viewport().get_visible_rect().size
	$Panel/VBoxContainer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	$Panel/VBoxContainer.add_theme_constant_override("separation", 16)
	$Panel/VBoxContainer/TitleLabel.add_theme_font_size_override("font_size", 32)
	$Panel/VBoxContainer/TitleLabel.add_theme_color_override("font_color", Color("#9B59B6"))
	$Panel/VBoxContainer/ScrollContainer/GridContainer.add_theme_constant_override("h_separation", 16)
	$Panel/VBoxContainer/ScrollContainer/GridContainer.add_theme_constant_override("v_separation", 16)
	build_characters()
	_update_gold_label()
	$Panel/VBoxContainer/ActionRow/BackButton.pressed.connect(_on_back)
	$Panel/VBoxContainer/ActionRow/PlayButton.pressed.connect(_on_play)
	$Panel/VBoxContainer/ActionRow/PlayButton.disabled = true

func _update_gold_label():
	if has_node("Panel/VBoxContainer/GoldLabel"):
		$Panel/VBoxContainer/GoldLabel.text = "💰 " + str(SaveManager.gold)

func build_characters():
	var container = $Panel/VBoxContainer/ScrollContainer/GridContainer
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

func _get_weapon_name(weapon_id: String) -> String:
	var names = {
		"bullet": "Mermi", "aura": "Aura", "chain": "Zincir", "boomerang": "Bumerang",
		"lightning": "Yıldırım", "ice_ball": "Buz Topu", "shadow": "Gölge", "laser": "Lazer",
		"holy_bullet": "Kutsal Mermi", "blood_boomerang": "Kan Bumerangı", "death_laser": "Ölüm Lazeri"
	}
	return names.get(weapon_id, weapon_id)

func _get_item_name(item_id: String) -> String:
	var names = {"lifesteal": "Can Çalma", "armor": "Zırh", "crit": "Kritik", "shield": "Kalkan"}
	return names.get(item_id, item_id)

func _build_rich_description(char_data: Dictionary, state: String) -> String:
	if state == "locked":
		if char_data["secret"]:
			return "🔒 " + char_data.get("unlock_hint", "???")
		return "🔒 " + char_data.get("unlock_hint", "")
	var parts: Array = []
	if char_data["start_weapon"] != "":
		parts.append("⚔ Başlangıç: " + _get_weapon_name(char_data["start_weapon"]))
	if char_data["start_item"] != "":
		parts.append("🛡 Item: " + _get_item_name(char_data["start_item"]))
	if char_data["bonus_damage"] > 0:
		parts.append("🗡 +" + str(char_data["bonus_damage"]) + " hasar")
	if char_data["bonus_hp"] > 0:
		parts.append("💗 +" + str(char_data["bonus_hp"]) + " max can")
	if char_data["bonus_speed"] > 0:
		parts.append("👟 +" + str(char_data["bonus_speed"]) + " hız")
	if char_data["bonus_armor"] > 0:
		parts.append("🛡 +" + str(char_data["bonus_armor"]) + " zırh")
	if char_data["special"] != "":
		var s = char_data["special"]
		if s == "lifesteal_15": parts.append("🩸 +%15 can çalma")
		elif s == "cooldown_10": parts.append("⚡ Cooldown -%10")
		elif s == "slow_double": parts.append("❄ Yavaşlatma 2x")
		elif s == "area_15": parts.append("💥 Alan +%15")
		elif s == "xp_20": parts.append("⭐ XP +%20")
		elif s == "all_weapons_1hp": parts.append("☠ 1 HP ile oyna, tüm silahlar aktif")
		elif s == "damage_double": parts.append("⚔ Hasar 2x")
		elif s == "random_weapons": parts.append("🎲 Rastgele silahlarla başla")
	if parts.is_empty():
		return char_data["description"]
	return "\n".join(parts)

func _build_card(i: int, char_data: Dictionary, state: String) -> PanelContainer:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(180, 340)
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
			desc_label.text = _build_rich_description(char_data, state)
			desc_label.add_theme_color_override("font_color", Color("#B0B0B0"))

			var btn = _make_button("Seç", Color("#3498DB"))
			var idx = i
			btn.pressed.connect(func(): _on_select(idx))
			vbox.add_child(char_visual)
			vbox.add_child(name_label)
			vbox.add_child(desc_label)
			vbox.add_child(btn)

		"unlocked":
			char_visual.color = Color(char_data["color"])
			name_label.text = char_data["name"]
			name_label.add_theme_color_override("font_color", Color(char_data["color"]))
			desc_label.text = _build_rich_description(char_data, state)
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

			bottom.text = "🔒 " + char_data.get("unlock_hint", "???")
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

func _on_purchase(char_id: String):
	if SaveManager.purchase_character(char_id):
		build_characters()
		_update_gold_label()

func _on_play():
	if selected_index < 0:
		return
	SaveManager.selected_character = selected_index
	SaveManager.save_game()
	get_tree().change_scene_to_file("res://ui/game_mode_select.tscn")

func _on_back():
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")
