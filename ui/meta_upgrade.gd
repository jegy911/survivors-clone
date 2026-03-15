extends CanvasLayer

var upgrade_defs = [
	{"id": "max_hp_bonus", "name": "💗 Max Can", "desc": "Başlangıç canı +25 per rank", "max_level": 5},
	{"id": "damage_bonus", "name": "⚔ Hasar Bonusu", "desc": "Tüm silahlar +5 hasar per rank", "max_level": 5},
	{"id": "speed_bonus", "name": "👟 Hareket Hızı", "desc": "Hareket hızı +10 per rank", "max_level": 5},
	{"id": "xp_bonus", "name": "⭐ XP Bonusu", "desc": "XP kazanımı +%10 per rank", "max_level": 5},
	{"id": "luck_bonus", "name": "🍀 Şans", "desc": "Nadir upgrade çıkma ihtimali artar", "max_level": 5},
	{"id": "reroll_bonus", "name": "🔄 Ekstra Reroll", "desc": "Level up'ta +1 reroll hakkı", "max_level": 3},
	{"id": "skip_bonus", "name": "⏭ Ekstra Skip", "desc": "Level up'ta +1 skip hakkı", "max_level": 3},
	{"id": "magnet_bonus", "name": "🧲 Mıknatıs", "desc": "XP çekim menzili +15 per rank", "max_level": 5},
	{"id": "cooldown_bonus", "name": "⚡ Cooldown Azaltma", "desc": "Tüm silahlar ateş hızı +%8 per rank", "max_level": 5},
	{"id": "area_bonus", "name": "💥 Alan Genişliği", "desc": "Aura/patlama/zincir menzili +%10 per rank", "max_level": 5},
	{"id": "duration_bonus", "name": "⏱ Süre Uzatma", "desc": "Zehir/yavaşlatma süresi +%15 per rank", "max_level": 5},
	{"id": "multi_attack_bonus", "name": "🎯 Çoklu Saldırı", "desc": "Tüm silahlar +1 ekstra saldırı per rank", "max_level": 3},
	{"id": "recovery_bonus", "name": "💚 Can Yenileme", "desc": "Her dakika +3 HP pasif iyileşme per rank", "max_level": 5},
	{"id": "armor_bonus", "name": "🛡 Başlangıç Zırhı", "desc": "Başlangıç zırhı +2 per rank", "max_level": 5},
	{"id": "gold_bonus", "name": "💰 Altın Bonusu", "desc": "Düşmandan +1 altın per rank", "max_level": 5},
	{"id": "crit_damage_bonus", "name": "🗡 Kritik Hasar", "desc": "Kritik vuruş çarpanı +%25 per rank", "max_level": 3},
	{"id": "start_level_bonus", "name": "📈 Başlangıç Seviyesi", "desc": "Oyun başında +1 level per rank", "max_level": 3},
	{"id": "growth_bonus", "name": "📦 Growth", "desc": "Kazanılan altın +%15 per rank", "max_level": 5},
	{"id": "curse_level", "name": "💀 Curse", "desc": "Düşman hızı/sayısı +%10 ama XP 2x per rank", "max_level": 5},
	{"id": "revival", "name": "✨ Revival", "desc": "Ölünce 1 kere %30 HP ile canlan", "max_level": 1},
	{"id": "adrenaline", "name": "🔥 Adrenalin", "desc": "Can azaldıkça hasar artar (+20 per %HP per rank)", "max_level": 5},
	{"id": "momentum", "name": "💨 Momentum", "desc": "Hareket ettikçe hasar bonusu (+1/sn per rank, max 10x)", "max_level": 5},
	{"id": "overheal", "name": "🛡 Overheal Kalkan", "desc": "Can doluyken iyileşme geçici kalkan verir", "max_level": 5},
]

var pending_reset = false

func _ready():
	var screen_size = get_viewport().get_visible_rect().size
	$Background.size = screen_size
	$Background.color = Color("#0D0D1A")
	$VBoxContainer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	$VBoxContainer.alignment = BoxContainer.ALIGNMENT_BEGIN
	$VBoxContainer.add_theme_constant_override("separation", 10)
	$VBoxContainer/TitleLabel.text = "META UPGRADES"
	$VBoxContainer/TitleLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$VBoxContainer/TitleLabel.add_theme_font_size_override("font_size", 36)
	$VBoxContainer/TitleLabel.add_theme_color_override("font_color", Color("#9B59B6"))
	update_gold_label()

	# Back butonu
	var back_style = StyleBoxFlat.new()
	back_style.bg_color = Color("#1A1A2E")
	back_style.corner_radius_top_left = 8
	back_style.corner_radius_top_right = 8
	back_style.corner_radius_bottom_left = 8
	back_style.corner_radius_bottom_right = 8
	$VBoxContainer/BackButton.add_theme_stylebox_override("normal", back_style)
	$VBoxContainer/BackButton.add_theme_color_override("font_color", Color.WHITE)
	$VBoxContainer/BackButton.text = "← Ana Menü"
	$VBoxContainer/BackButton.custom_minimum_size = Vector2(200, 50)
	$VBoxContainer/BackButton.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	$VBoxContainer/BackButton.pressed.connect(_on_back)

	$VBoxContainer/ScrollContainer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	$VBoxContainer/ScrollContainer.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	$VBoxContainer/ScrollContainer/UpgradeList.add_theme_constant_override("separation", 12)
	build_upgrade_list()

func build_upgrade_list():
	var list = $VBoxContainer/ScrollContainer/UpgradeList
	for child in list.get_children():
		child.queue_free()
	list.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var grid = GridContainer.new()
	grid.columns = 3
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 16)
	list.add_child(grid)

	for upgrade in upgrade_defs:
		var level = SaveManager.meta_upgrades.get(upgrade["id"], 0)
		var max_level = upgrade["max_level"]
		var cost = SaveManager.get_upgrade_cost(upgrade["id"], level)
		var is_maxed = level >= max_level

		var card = PanelContainer.new()
		card.custom_minimum_size = Vector2(280, 100)
		var card_style = StyleBoxFlat.new()
		card_style.bg_color = Color("#1A1A2E")
		card_style.corner_radius_top_left = 10
		card_style.corner_radius_top_right = 10
		card_style.corner_radius_bottom_left = 10
		card_style.corner_radius_bottom_right = 10
		card_style.border_width_left = 1
		card_style.border_width_right = 1
		card_style.border_width_top = 1
		card_style.border_width_bottom = 1
		card_style.border_color = Color("#3498DB") if is_maxed else Color("#333355")
		card.add_theme_stylebox_override("panel", card_style)

		var row = HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_theme_constant_override("separation", 12)

		var info = VBoxContainer.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var name_label = Label.new()
		name_label.text = upgrade["name"] + "  [" + str(level) + "/" + str(max_level) + "]"
		name_label.add_theme_color_override("font_color", Color("#FFD700") if is_maxed else Color.WHITE)
		name_label.add_theme_font_size_override("font_size", 18)

		var desc_label = Label.new()
		desc_label.text = upgrade["desc"]
		desc_label.add_theme_color_override("font_color", Color("#AAAAAA"))

		info.add_child(name_label)
		info.add_child(desc_label)

		var btn = Button.new()
		if is_maxed:
			btn.text = "✓ MAX"
			btn.disabled = true
		else:
			btn.text = str(cost) + " 💰"
			btn.disabled = SaveManager.gold < cost

		btn.custom_minimum_size = Vector2(120, 50)
		var btn_style = StyleBoxFlat.new()
		btn_style.bg_color = Color("#2A2A2A") if is_maxed else Color("#1A1A2E")
		btn_style.corner_radius_top_left = 8
		btn_style.corner_radius_top_right = 8
		btn_style.corner_radius_bottom_left = 8
		btn_style.corner_radius_bottom_right = 8
		btn.add_theme_stylebox_override("normal", btn_style)
		btn.add_theme_color_override("font_color", Color("#FFD700") if is_maxed else Color.WHITE)

		var upgrade_id = upgrade["id"]
		btn.pressed.connect(func(): _on_upgrade_pressed(upgrade_id, cost))

		row.add_child(info)
		row.add_child(btn)
		card.add_child(row)
		grid.add_child(card)

	# Reset butonu — listenin en altında
	var reset_btn = Button.new()
	if pending_reset:
		reset_btn.text = "⚠ Emin misin? Tekrar bas!"
		reset_btn.add_theme_color_override("font_color", Color("#E74C3C"))
	else:
		reset_btn.text = "🔄 Tüm Upgradeleri Sıfırla"
		reset_btn.add_theme_color_override("font_color", Color("#E74C3C"))
	reset_btn.custom_minimum_size = Vector2(300, 55)
	reset_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var reset_style = StyleBoxFlat.new()
	reset_style.bg_color = Color("#2A0A0A")
	reset_style.border_color = Color("#E74C3C")
	reset_style.border_width_left = 2
	reset_style.border_width_right = 2
	reset_style.border_width_top = 2
	reset_style.border_width_bottom = 2
	reset_style.corner_radius_top_left = 8
	reset_style.corner_radius_top_right = 8
	reset_style.corner_radius_bottom_left = 8
	reset_style.corner_radius_bottom_right = 8
	reset_btn.add_theme_stylebox_override("normal", reset_style)
	reset_btn.pressed.connect(_on_reset_pressed)
	list.add_child(reset_btn)

func update_gold_label():
	$VBoxContainer/GoldLabel.text = "💰 Altın: " + str(SaveManager.gold)
	$VBoxContainer/GoldLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$VBoxContainer/GoldLabel.add_theme_color_override("font_color", Color("#F5E642"))
	$VBoxContainer/GoldLabel.add_theme_font_size_override("font_size", 22)

func _on_upgrade_pressed(upgrade_id: String, cost: int):
	if SaveManager.spend_gold(cost):
		SaveManager.meta_upgrades[upgrade_id] += 1
		SaveManager.save_game()
		update_gold_label()
		build_upgrade_list()

func _on_reset_pressed():
	if pending_reset:
		SaveManager.reset_meta_upgrades()
		pending_reset = false
		update_gold_label()
		build_upgrade_list()
	else:
		pending_reset = true
		build_upgrade_list()

func _on_back():
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")
