extends CanvasLayer

signal upgrade_chosen(upgrade_id)

var weapon_upgrades = ["bullet", "aura", "chain", "boomerang", "lightning", "ice_ball", "shadow", "laser", "fan_blade", "hex_sigil", "gravity_anchor", "bastion_flail", "shield_ram"]
var item_upgrades = ["lifesteal", "armor", "crit", "explosion", "magnet", "poison", "shield", "speed_charm", "blood_pool", "luck_stone", "turbine", "steam_armor", "energy_cell", "ember_heart", "glyph_charm", "resonance_stone", "rampart_plate", "iron_bulwark"]
var stat_upgrades = ["speed", "max_hp", "heal"]

func _leading_icon(id: String, is_evolution: bool) -> String:
	if is_evolution or WeaponEvolution.EVOLUTIONS.has(id):
		return "⚡ "
	if id in stat_upgrades:
		match id:
			"speed":
				return "👟 "
			"max_hp":
				return "❤️ "
			"heal":
				return "💚 "
			_:
				return "✨ "
	if id in weapon_upgrades or id in item_upgrades:
		return ""
	return ""

func _stat_upgrade_text(id: String) -> String:
	var key_map = {"speed": "stat_speed", "max_hp": "stat_max_hp", "heal": "stat_heal"}
	var k = key_map.get(id, id)
	return tr("ui.upgrade_ui." + k)

var player_ref = null
var current_pool = []
var chosen_upgrades = []

var reroll_count = 2
var skip_count = 2
var pick_count: int = 3


func _option_buttons() -> Array:
	return [
		$Panel/VBoxContainer/HBoxContainer/Option1,
		$Panel/VBoxContainer/HBoxContainer/Option2,
		$Panel/VBoxContainer/HBoxContainer/Option3,
		$Panel/VBoxContainer/HBoxContainer/Option4,
	]


func _layout_levelup_panel(n_options: int) -> void:
	var screen_size = get_viewport().get_visible_rect().size
	var panel_w = 1000 if n_options >= 4 else 800
	var btn_w = 190 if n_options >= 4 else 220
	$Panel.size = Vector2(panel_w, 420)
	$Panel.position = screen_size / 2 - $Panel.size / 2
	for btn in _option_buttons():
		btn.custom_minimum_size = Vector2(btn_w, 150)


func _ready():
	var screen_size = get_viewport().get_visible_rect().size
	$Panel.size = Vector2(800, 420)
	$Panel.position = screen_size / 2 - $Panel.size / 2
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#0D0D1A")
	style.border_color = Color("#FFD700")
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	$Panel.add_theme_stylebox_override("panel", style)
	
	$Panel/VBoxContainer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	$Panel/VBoxContainer.alignment = BoxContainer.ALIGNMENT_CENTER
	$Panel/VBoxContainer.add_theme_constant_override("separation", 16)
	
	$Panel/VBoxContainer/HBoxContainer.alignment = BoxContainer.ALIGNMENT_CENTER
	$Panel/VBoxContainer/HBoxContainer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	$Panel/VBoxContainer/HBoxContainer.add_theme_constant_override("separation", 16)
	
	$Panel/VBoxContainer/TitleLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$Panel/VBoxContainer/TitleLabel.add_theme_font_size_override("font_size", 24)
	$Panel/VBoxContainer/TitleLabel.add_theme_color_override("font_color", Color.WHITE)
	
	for btn in _option_buttons():
		var btn_style = StyleBoxFlat.new()
		btn_style.bg_color = Color(0.15, 0.15, 0.25, 1)
		btn_style.corner_radius_top_left = 8
		btn_style.corner_radius_top_right = 8
		btn_style.corner_radius_bottom_left = 8
		btn_style.corner_radius_bottom_right = 8
		btn.add_theme_stylebox_override("normal", btn_style)
		btn.add_theme_color_override("font_color", Color.WHITE)
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	$Panel/VBoxContainer/ActionRow.alignment = BoxContainer.ALIGNMENT_CENTER
	$Panel/VBoxContainer/ActionRow.add_theme_constant_override("separation", 16)
	
	for btn in [$Panel/VBoxContainer/ActionRow/RerollButton,
				$Panel/VBoxContainer/ActionRow/SkipButton]:
		btn.custom_minimum_size = Vector2(160, 45)
		var btn_style = StyleBoxFlat.new()
		btn_style.bg_color = Color("#1A1A2E")
		btn_style.corner_radius_top_left = 8
		btn_style.corner_radius_top_right = 8
		btn_style.corner_radius_bottom_left = 8
		btn_style.corner_radius_bottom_right = 8
		btn.add_theme_stylebox_override("normal", btn_style)
		btn.add_theme_color_override("font_color", Color.WHITE)
		btn.add_theme_font_size_override("font_size", 16)
	
	_layout_levelup_panel(3)
	
	$Panel/VBoxContainer/HBoxContainer/Option1.pressed.connect(_on_option1)
	$Panel/VBoxContainer/HBoxContainer/Option2.pressed.connect(_on_option2)
	$Panel/VBoxContainer/HBoxContainer/Option3.pressed.connect(_on_option3)
	$Panel/VBoxContainer/HBoxContainer/Option4.pressed.connect(_on_option4)
	$Panel/VBoxContainer/ActionRow/RerollButton.pressed.connect(_on_reroll)
	$Panel/VBoxContainer/ActionRow/SkipButton.pressed.connect(_on_skip)

func build_pool() -> Array:
	var pool = []
	var luck = player_ref.get_luck()
	
	# Evrim seçenekleri — en yüksek öncelik (havuz sırası get_available_evolutions içinde karıştırılır)
	var available_evos = WeaponEvolution.get_available_evolutions(player_ref)
	for evo_id in available_evos:
		pool.append({
			"id": evo_id,
			"weight": WeaponEvolution.get_evolution_weight(evo_id),
			"is_evolution": true
		})
	
	for id in stat_upgrades:
		pool.append({"id": id, "weight": 1.5, "is_evolution": false})
	
	for id in weapon_upgrades:
		if player_ref.active_weapons.has(id):
			var w = player_ref.active_weapons[id]
			if w.level < w.max_level:
				pool.append({"id": id, "weight": 2.0 + luck * 0.5, "is_evolution": false})
		else:
			if player_ref.can_add_weapon():
				pool.append({"id": id, "weight": 0.3 + luck * 0.2, "is_evolution": false})
	for id in item_upgrades:
		if player_ref.active_items.has(id):
			var i = player_ref.active_items[id]
			if i.level < i.max_level:
				pool.append({"id": id, "weight": 2.0 + luck * 0.5, "is_evolution": false})
		else:
			if player_ref.can_add_item():
				pool.append({"id": id, "weight": 0.3 + luck * 0.2, "is_evolution": false})
	
	return pool

func weighted_pick(pool: Array, count: int) -> Array:
	var chosen = []
	var remaining = pool.duplicate()
	
	# Evrimler her zaman önce göster
	var evolutions = remaining.filter(func(x): return x.get("is_evolution", false))
	var non_evolutions = remaining.filter(func(x): return not x.get("is_evolution", false))
	
	for evo in evolutions:
		if chosen.size() < count:
			chosen.append(evo)
			remaining.erase(evo)
	
	remaining = non_evolutions
	
	for _i in count - chosen.size():
		if remaining.is_empty():
			break
		var total_weight = 0.0
		for item in remaining:
			total_weight += item["weight"]
		var roll = randf() * total_weight
		var cumulative = 0.0
		for j in remaining.size():
			cumulative += remaining[j]["weight"]
			if roll <= cumulative:
				chosen.append(remaining[j])
				remaining.remove_at(j)
				break
	
	return chosen

func get_upgrade_text(id: String) -> String:
	if player_ref == null:
		return id
	
	# Evrim silahı mı?
	if WeaponEvolution.EVOLUTIONS.has(id):
		var title = tr("ui.upgrade_ui.evolution_pick_title")
		return title + "\n" + WeaponEvolution.localized_name(id) + "\n" + WeaponEvolution.localized_description(id)
	
	if id in weapon_upgrades:
		return tr("ui.upgrade_ui.option_weapon_prefix") + "\n" + player_ref.get_weapon_description(id)
	if id in item_upgrades:
		return tr("ui.upgrade_ui.option_item_prefix") + "\n" + player_ref.get_item_description(id)
	if id in stat_upgrades:
		return _stat_upgrade_text(id)
	return id

func refresh_buttons():
	var buttons = _option_buttons()
	
	for i in chosen_upgrades.size():
		var upgrade = chosen_upgrades[i]
		var ic := _leading_icon(upgrade["id"], upgrade.get("is_evolution", false))
		buttons[i].text = ic + "\n" + get_upgrade_text(upgrade["id"])
		buttons[i].set_meta("upgrade_id", upgrade["id"])
		buttons[i].visible = true
		
		# Evrim ise altın rengi stil
		if upgrade.get("is_evolution", false):
			var evo_style = StyleBoxFlat.new()
			evo_style.bg_color = Color("#2A1A00")
			evo_style.border_color = Color("#FFD700")
			evo_style.border_width_top = 2
			evo_style.border_width_bottom = 2
			evo_style.border_width_left = 2
			evo_style.border_width_right = 2
			evo_style.corner_radius_top_left = 8
			evo_style.corner_radius_top_right = 8
			evo_style.corner_radius_bottom_left = 8
			evo_style.corner_radius_bottom_right = 8
			buttons[i].add_theme_stylebox_override("normal", evo_style)
			buttons[i].add_theme_color_override("font_color", Color("#FFD700"))
		else:
			var normal_style = StyleBoxFlat.new()
			normal_style.bg_color = Color(0.15, 0.15, 0.25, 1)
			normal_style.corner_radius_top_left = 8
			normal_style.corner_radius_top_right = 8
			normal_style.corner_radius_bottom_left = 8
			normal_style.corner_radius_bottom_right = 8
			buttons[i].add_theme_stylebox_override("normal", normal_style)
			buttons[i].add_theme_color_override("font_color", Color.WHITE)
	
	for i in range(chosen_upgrades.size(), buttons.size()):
		buttons[i].visible = false
	
	$Panel/VBoxContainer/ActionRow/RerollButton.text = tr("ui.upgrade_ui.reroll") % reroll_count
	$Panel/VBoxContainer/ActionRow/RerollButton.disabled = reroll_count <= 0
	$Panel/VBoxContainer/ActionRow/SkipButton.text = tr("ui.upgrade_ui.skip") % skip_count
	$Panel/VBoxContainer/ActionRow/SkipButton.disabled = skip_count <= 0

func show_upgrades(player):
	player_ref = player
	reroll_count = 2 + SaveManager.meta_upgrades.get("reroll_bonus", 0)
	skip_count = 2 + SaveManager.meta_upgrades.get("skip_bonus", 0)
	
	pick_count = 4 if player_ref.get("cog_shard_bonus_active") else 3
	_layout_levelup_panel(pick_count)
	
	current_pool = build_pool()
	chosen_upgrades = weighted_pick(current_pool, pick_count)
	if player_ref.get("cog_shard_bonus_active"):
		player_ref.cog_shard_bonus_active = false
	
	var char_index = SaveManager.selected_character if player_ref.player_id == 0 else SaveManager.selected_character_p2
	var char_name = CharacterData.CHARACTERS[char_index]["name"]
	var player_label = "P1" if player_ref.player_id == 0 else "P2"
	if SaveManager.game_mode == "local_coop":
		$Panel/VBoxContainer/TitleLabel.text = tr("ui.upgrade_ui.title_coop") % [char_name, player_label, player_ref.level]
	else:
		$Panel/VBoxContainer/TitleLabel.text = tr("ui.upgrade_ui.title_solo") % player_ref.level
	$Panel/VBoxContainer/TitleLabel.add_theme_color_override("font_color", Color("#FFD700"))
	refresh_buttons()
	visible = true

func _on_option1():
	upgrade_chosen.emit($Panel/VBoxContainer/HBoxContainer/Option1.get_meta("upgrade_id"))
	visible = false

func _on_option2():
	upgrade_chosen.emit($Panel/VBoxContainer/HBoxContainer/Option2.get_meta("upgrade_id"))
	visible = false

func _on_option3():
	upgrade_chosen.emit($Panel/VBoxContainer/HBoxContainer/Option3.get_meta("upgrade_id"))
	visible = false

func _on_option4():
	upgrade_chosen.emit($Panel/VBoxContainer/HBoxContainer/Option4.get_meta("upgrade_id"))
	visible = false

func _on_reroll():
	if reroll_count <= 0:
		return
	reroll_count -= 1
	current_pool = build_pool()
	chosen_upgrades = weighted_pick(current_pool, pick_count)
	refresh_buttons()

func _on_skip():
	if skip_count <= 0:
		return
	skip_count -= 1
	player_ref.gain_xp(int(player_ref.xp_to_next_level * 0.3))
	upgrade_chosen.emit("skip")
	visible = false
