extends CanvasLayer

var upgrade_defs = [
	# --- SAVAŞ ---
	{"id": "damage_bonus", "name": "⚔ Hasar Bonusu", "desc": "Tüm silahlar +5 hasar\n(max rank: +25 hasar)", "max_level": 5, "category": "combat"},
	{"id": "cooldown_bonus", "name": "⚡ Cooldown Azaltma", "desc": "Ateş hızı +%8 per rank\n(max rank: -%40 cooldown)", "max_level": 5, "category": "combat"},
	{"id": "area_bonus", "name": "💥 Alan Genişliği", "desc": "Saldırı alanı +%10 per rank\n(max rank: +%50 alan)", "max_level": 5, "category": "combat"},
	{"id": "multi_attack_bonus", "name": "🎯 Çoklu Saldırı", "desc": "Tüm silahlar +1 ekstra saldırı\n(max rank: +3 saldırı)", "max_level": 3, "category": "combat"},
	{"id": "crit_damage_bonus", "name": "🗡 Kritik Hasar", "desc": "Kritik vuruş çarpanı +%25\n(max rank: 2x → 2.75x)", "max_level": 3, "category": "combat"},
	{"id": "duration_bonus", "name": "⏱ Süre Uzatma", "desc": "Zehir/yavaşlatma süresi +%15\n(max rank: +%75 süre)", "max_level": 5, "category": "combat"},
	{"id": "adrenaline", "name": "🔥 Adrenalin", "desc": "Eksik can başına +20 hasar\n(düşük canda daha güçlü)", "max_level": 5, "category": "combat"},
	{"id": "momentum", "name": "💨 Momentum", "desc": "Hareket ettikçe +1 hasar/sn\n(max rank: +10 hasar bonusu)", "max_level": 5, "category": "combat"},

	# --- SAVUNMA ---
	{"id": "max_hp_bonus", "name": "💗 Max Can", "desc": "Başlangıç canı +25 per rank\n(max rank: +125 can)", "max_level": 5, "category": "defense"},
	{"id": "armor_bonus", "name": "🛡 Başlangıç Zırhı", "desc": "Başlangıç zırhı +2 per rank\n(max rank: -10 hasar)", "max_level": 5, "category": "defense"},
	{"id": "recovery_bonus", "name": "💚 Can Yenileme", "desc": "Her dakika +3 HP iyileşme\n(max rank: +15 HP/dk)", "max_level": 5, "category": "defense"},
	{"id": "revival", "name": "✨ Revival", "desc": "Ölünce 1 kere %30 HP ile canlan\n(max rank: 1 kullanım)", "max_level": 1, "category": "defense"},
	{"id": "overheal", "name": "🔰 Overheal Kalkan", "desc": "Can doluyken iyileşme\ngeçici kalkan verir", "max_level": 5, "category": "defense"},

	# --- İLERLEME ---
	{"id": "xp_bonus", "name": "⭐ XP Bonusu", "desc": "XP kazanımı +%10 per rank\n(max rank: +%50 XP)", "max_level": 5, "category": "progress"},
	{"id": "luck_bonus", "name": "🍀 Şans", "desc": "Nadir upgrade ihtimali +%10\n(max rank: +%50 şans)", "max_level": 5, "category": "progress"},
	{"id": "magnet_bonus", "name": "🧲 Mıknatıs", "desc": "XP/gold çekim menzili +15\n(max rank: +75 menzil)", "max_level": 5, "category": "progress"},
	{"id": "gold_bonus", "name": "💰 Altın Bonusu", "desc": "Düşmandan +1 altın per rank\n(max rank: +5 altın)", "max_level": 5, "category": "progress"},
	{"id": "growth_bonus", "name": "📦 Altın Çarpanı", "desc": "Kazanılan altın +%15 per rank\n(max rank: +%75 altın)", "max_level": 5, "category": "progress"},
	{"id": "start_level_bonus", "name": "📈 Başlangıç Seviyesi", "desc": "En az 1 rank: koşuya 2. seviyede başla (+1 net).\nRank 2–3 şimdilik aynı (ileride ek ödül planlanıyor).", "max_level": 3, "category": "progress"},
	{"id": "reroll_bonus", "name": "🔄 Ekstra Reroll", "desc": "Koşu başına +1 reroll (havuz)\n(max rank: +3)", "max_level": 3, "category": "progress"},
	{"id": "skip_bonus", "name": "⏭ Ekstra Skip", "desc": "Koşu başına +1 skip (havuz)\n(max rank: +3)", "max_level": 3, "category": "progress"},
	{"id": "weapon_slot_bonus", "name": "🔢 Silah Slotu", "desc": "+1 silah slotu (max 2 rank, toplam +2)", "max_level": 2, "category": "progress"},
	{"id": "item_slot_bonus", "name": "🧰 Eşya Slotu", "desc": "+1 eşya slotu (max 2 rank, toplam +2)", "max_level": 2, "category": "progress"},

	# --- ZOR MOD ---
	{"id": "speed_bonus", "name": "👟 Hareket Hızı", "desc": "Hareket hızı +10 per rank\n(max rank: +50 hız)", "max_level": 5, "category": "utility"},
	{"id": "curse_level", "name": "💀 Curse", "desc": "Düşman güç/sayısı +%10\nKarşılığında XP 2x per rank", "max_level": 5, "category": "curse"},
]

var pending_reset = false

func _ready():
	if not LocalizationManager.locale_changed.is_connected(_on_locale_changed):
		LocalizationManager.locale_changed.connect(_on_locale_changed)
	$MarginRoot/VBoxContainer/TitleLabel.text = tr("ui.meta_screen.title")
	$MarginRoot/VBoxContainer/TitleLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$MarginRoot/VBoxContainer/TitleLabel.add_theme_font_size_override("font_size", 36)
	$MarginRoot/VBoxContainer/TitleLabel.add_theme_color_override("font_color", Color("#9B59B6"))
	update_gold_label()

	$MarginRoot/VBoxContainer/BackButton.text = tr("ui.meta_screen.back")
	$MarginRoot/VBoxContainer/BackButton.custom_minimum_size = Vector2(220, 52)
	$MarginRoot/VBoxContainer/BackButton.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	ButtonCoverStyles.apply($MarginRoot/VBoxContainer/BackButton, 0, 17, Vector4(18.0, 8.0, 18.0, 8.0))
	$MarginRoot/VBoxContainer/BackButton.pressed.connect(_on_back)

	var scroll: ScrollContainer = $MarginRoot/VBoxContainer/ScrollContainer
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	var scroll_style = StyleBoxFlat.new()
	scroll_style.bg_color = Color("#0D0D1A")
	scroll.add_theme_stylebox_override("panel", scroll_style)
	$MarginRoot/VBoxContainer/ScrollContainer/UpgradeList.add_theme_constant_override("separation", 12)
	build_upgrade_list()

func _on_locale_changed(_locale: String) -> void:
	$MarginRoot/VBoxContainer/TitleLabel.text = tr("ui.meta_screen.title")
	$MarginRoot/VBoxContainer/BackButton.text = tr("ui.meta_screen.back")
	update_gold_label()
	build_upgrade_list()

func build_upgrade_list():
	var list = $MarginRoot/VBoxContainer/ScrollContainer/UpgradeList
	for child in list.get_children():
		child.queue_free()

	var grid = GridContainer.new()
	grid.columns = 3
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 16)
	list.add_child(grid)

	var upgrade_idx := 0
	for upgrade in upgrade_defs:
		var level = SaveManager.meta_upgrades.get(upgrade["id"], 0)
		var max_level = upgrade["max_level"]
		var cost = SaveManager.get_upgrade_cost(upgrade["id"], level)
		var is_maxed = level >= max_level

		var card = PanelContainer.new()
		card.custom_minimum_size = Vector2(280, 100)
		card.mouse_filter = Control.MOUSE_FILTER_STOP
		card.tooltip_text = tr("meta." + upgrade["id"] + ".desc")
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
		var category_colors = {
	"combat": Color("#E74C3C"),
	"defense": Color("#3498DB"),
	"progress": Color("#2ECC71"),
	"utility": Color("#F39C12"),
	"curse": Color("#9B59B6"),
}
		var cat = upgrade.get("category", "utility")
		card_style.border_color = Color("#FFD700") if is_maxed else category_colors.get(cat, Color("#333355"))
		card.add_theme_stylebox_override("panel", card_style)

		var row = HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_theme_constant_override("separation", 12)

		var info = VBoxContainer.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var name_label = Label.new()
		var uid = upgrade["id"]
		name_label.text = tr("meta." + uid + ".name") + "  [" + str(level) + "/" + str(max_level) + "]"
		name_label.add_theme_color_override("font_color", Color("#FFD700") if is_maxed else Color.WHITE)
		name_label.add_theme_font_size_override("font_size", 18)

		var desc_label = Label.new()
		var show_desc_on_card: bool = uid == "damage_bonus"
		desc_label.visible = show_desc_on_card
		desc_label.text = tr("meta." + uid + ".desc") if show_desc_on_card else ""
		desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_label.add_theme_color_override("font_color", Color("#AAAAAA"))

		info.add_child(name_label)
		info.add_child(desc_label)

		var btn = Button.new()
		if is_maxed:
			btn.text = tr("ui.meta_screen.max")
			btn.disabled = true
		else:
			btn.text = tr("ui.meta_screen.cost") % cost
			btn.disabled = SaveManager.gold < cost

		btn.custom_minimum_size = Vector2(120, 50)
		var cv: int = upgrade_idx % 3
		var mod := Color(0.72, 0.72, 0.75, 0.88) if is_maxed else Color.WHITE
		ButtonCoverStyles.apply(
			btn,
			cv,
			15,
			Vector4(10.0, 7.0, 10.0, 7.0),
			mod,
			Color("#FFD700") if is_maxed else Color.WHITE,
			true,
		)

		var upgrade_id = upgrade["id"]
		btn.pressed.connect(func(): _on_upgrade_pressed(upgrade_id, cost))

		row.add_child(info)
		row.add_child(btn)
		card.add_child(row)
		grid.add_child(card)
		upgrade_idx += 1

	# Reset butonu — listenin en altında
	var reset_btn = Button.new()
	if pending_reset:
		reset_btn.text = tr("ui.meta_screen.reset_confirm")
	else:
		reset_btn.text = tr("ui.meta_screen.reset_all")
	reset_btn.custom_minimum_size = Vector2(300, 55)
	reset_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	ButtonCoverStyles.apply(reset_btn, 2, 16, Vector4(22.0, 8.0, 22.0, 8.0), Color(1.15, 0.82, 0.82, 1.0), Color("#E74C3C"))
	reset_btn.pressed.connect(_on_reset_pressed)
	list.add_child(reset_btn)

func update_gold_label():
	$MarginRoot/VBoxContainer/GoldLabel.text = tr("ui.meta_screen.gold") % SaveManager.gold
	$MarginRoot/VBoxContainer/GoldLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$MarginRoot/VBoxContainer/GoldLabel.add_theme_color_override("font_color", Color("#F5E642"))
	$MarginRoot/VBoxContainer/GoldLabel.add_theme_font_size_override("font_size", 22)

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


func _unhandled_input(event: InputEvent) -> void:
	if MenuInput.is_menu_back_pressed(event):
		get_viewport().set_input_as_handled()
		_on_back()
