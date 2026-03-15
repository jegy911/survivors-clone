extends CanvasLayer

signal upgrade_chosen(upgrade_id)

var weapon_upgrades = ["bullet", "aura", "chain", "boomerang", "lightning", "ice_ball", "shadow", "laser"]
var item_upgrades = ["lifesteal", "armor", "crit", "explosion", "magnet", "poison", "shield", "speed_charm", "blood_pool", "luck_stone"]
var stat_upgrades = ["speed", "max_hp", "heal"]
var stat_upgrades = []

var stat_texts = {
	"speed": "Hareket Hızı +20\nHareket hızını artırır",
	"max_hp": "Max Can +25\nMaksimum canı artırır",
	"heal": "Anında +20 Can\nHemen can yeniler",
}

var player_ref = null
var current_pool = []
var chosen_upgrades = []

var reroll_count = 2
var skip_count = 2

func _ready():
	var screen_size = get_viewport().get_visible_rect().size
	$Panel.size = Vector2(800, 380)
	$Panel.position = screen_size / 2 - $Panel.size / 2
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#0D0D1A")
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
	
	for btn in [$Panel/VBoxContainer/HBoxContainer/Option1,
				$Panel/VBoxContainer/HBoxContainer/Option2,
				$Panel/VBoxContainer/HBoxContainer/Option3]:
		btn.custom_minimum_size = Vector2(220, 130)
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
	
	$Panel/VBoxContainer/HBoxContainer/Option1.pressed.connect(_on_option1)
	$Panel/VBoxContainer/HBoxContainer/Option2.pressed.connect(_on_option2)
	$Panel/VBoxContainer/HBoxContainer/Option3.pressed.connect(_on_option3)
	$Panel/VBoxContainer/ActionRow/RerollButton.pressed.connect(_on_reroll)
	$Panel/VBoxContainer/ActionRow/SkipButton.pressed.connect(_on_skip)

func build_pool() -> Array:
	var pool = []
	var luck = player_ref.get_luck()
	
	# Evrim seçenekleri — en yüksek öncelik
	var available_evos = WeaponEvolution.get_available_evolutions(player_ref)
	for evo_id in available_evos:
		var evo = WeaponEvolution.EVOLUTIONS[evo_id]
		pool.append({"id": evo_id, "weight": 10.0, "is_evolution": true})
	
	for id in stat_upgrades:
		pool.append({"id": id, "weight": 1.0, "is_evolution": false})
	
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
		var evo = WeaponEvolution.EVOLUTIONS[id]
		return "⚡ EVRİM: " + evo["name"] + "\n" + evo["description"]
	
	match id:
		"bullet", "aura", "chain", "boomerang", "lightning", "ice_ball", "shadow", "laser":
			return "⚔ SİLAH\n" + player_ref.get_weapon_description(id)
		"lifesteal", "armor", "crit", "explosion", "magnet", "poison", "shield", "speed_charm", "blood_pool", "luck_stone":
			return "🛡 EŞYA\n" + player_ref.get_item_description(id)
		_:
			return "🛡 EŞYA\n" + stat_texts.get(id, id)

func refresh_buttons():
	var buttons = [$Panel/VBoxContainer/HBoxContainer/Option1,
				   $Panel/VBoxContainer/HBoxContainer/Option2,
				   $Panel/VBoxContainer/HBoxContainer/Option3]
	
	for i in chosen_upgrades.size():
		var upgrade = chosen_upgrades[i]
		buttons[i].text = get_upgrade_text(upgrade["id"])
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
	
	for i in range(chosen_upgrades.size(), 3):
		buttons[i].visible = false
	
	$Panel/VBoxContainer/ActionRow/RerollButton.text = "🔄 Reroll (" + str(reroll_count) + ")"
	$Panel/VBoxContainer/ActionRow/RerollButton.disabled = reroll_count <= 0
	$Panel/VBoxContainer/ActionRow/SkipButton.text = "⏭ Skip (" + str(skip_count) + ")"
	$Panel/VBoxContainer/ActionRow/SkipButton.disabled = skip_count <= 0

func show_upgrades(player):
	player_ref = player
	reroll_count = 2 + SaveManager.meta_upgrades.get("reroll_bonus", 0)
	skip_count = 2 + SaveManager.meta_upgrades.get("skip_bonus", 0)
	
	current_pool = build_pool()
	chosen_upgrades = weighted_pick(current_pool, 3)
	
	$Panel/VBoxContainer/TitleLabel.text = "— LEVEL UP —"
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

func _on_reroll():
	if reroll_count <= 0:
		return
	reroll_count -= 1
	current_pool = build_pool()
	chosen_upgrades = weighted_pick(current_pool, 3)
	refresh_buttons()

func _on_skip():
	if skip_count <= 0:
		return
	skip_count -= 1
	player_ref.gain_xp(int(player_ref.xp_to_next_level * 0.3))
	upgrade_chosen.emit("skip")
	visible = false
