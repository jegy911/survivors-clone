extends CanvasLayer

var current_tab = "ses"
var _confirm_reset_full = false
var _confirm_reset_stats = false
var _dev_gold_amount = 1000

func _ready():
	var screen_size = get_viewport().get_visible_rect().size
	$Background.size = screen_size
	$Background.color = Color("#0D0D1A")
	
	_build_ui()

func _build_ui():
	var vbox = $VBoxContainer
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.alignment = BoxContainer.ALIGNMENT_BEGIN
	vbox.add_theme_constant_override("separation", 0)
	
	# Başlık
	$VBoxContainer/TitleLabel.text = "AYARLAR"
	$VBoxContainer/TitleLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$VBoxContainer/TitleLabel.add_theme_font_size_override("font_size", 36)
	$VBoxContainer/TitleLabel.add_theme_color_override("font_color", Color("#9B59B6"))
	
	# Tab butonları
	_style_tab_button($VBoxContainer/TabRow/SesTab, "🔊 Ses")
	_style_tab_button($VBoxContainer/TabRow/GoruntuTab, "🖥 Görüntü")
	_style_tab_button($VBoxContainer/TabRow/OynanisTab, "🎮 Oynanış")
	_style_tab_button($VBoxContainer/TabRow/ProfilTab, "👤 Profil")
	_style_tab_button($VBoxContainer/TabRow/DevToolsTab, "🛠 Dev")
	$VBoxContainer/TabRow/DevToolsTab.pressed.connect(func(): _switch_tab("devtools"))
	
	$VBoxContainer/TabRow/SesTab.pressed.connect(func(): _switch_tab("ses"))
	$VBoxContainer/TabRow/GoruntuTab.pressed.connect(func(): _switch_tab("goruntu"))
	$VBoxContainer/TabRow/OynanisTab.pressed.connect(func(): _switch_tab("oynanis"))
	$VBoxContainer/TabRow/ProfilTab.pressed.connect(func(): _switch_tab("profil"))
	
	# Geri butonu
	_style_back_button($VBoxContainer/BackButton)
	$VBoxContainer/BackButton.pressed.connect(_on_back)
	
	_switch_tab("ses")

func _style_tab_button(btn: Button, text: String):
	btn.text = text
	btn.custom_minimum_size = Vector2(180, 50)
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#1A1A2E")
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 0
	style.corner_radius_bottom_right = 0
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.add_theme_font_size_override("font_size", 16)

func _style_back_button(btn: Button):
	btn.text = "← Ana Menü"
	btn.custom_minimum_size = Vector2(200, 50)
	btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#1A1A2E")
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_color_override("font_color", Color.WHITE)

func _switch_tab(tab: String):
	current_tab = tab
	var content = $VBoxContainer/ContentArea
	for child in content.get_children():
		child.queue_free()
	
	match tab:
		"ses": _build_ses_tab(content)
		"goruntu": _build_goruntu_tab(content)
		"oynanis": _build_oynanis_tab(content)
		"profil": _build_profil_tab(content)
		"devtools": _build_devtools_tab(content)
	
	var tabs = {
		"ses": $VBoxContainer/TabRow/SesTab,
		"goruntu": $VBoxContainer/TabRow/GoruntuTab,
		"oynanis": $VBoxContainer/TabRow/OynanisTab,
		"profil": $VBoxContainer/TabRow/ProfilTab,
		"devtools": $VBoxContainer/TabRow/DevToolsTab,
	}
	for t in tabs:
		var style = StyleBoxFlat.new()
		style.bg_color = Color("#9B59B6") if t == tab else Color("#1A1A2E")
		style.corner_radius_top_left = 8
		style.corner_radius_top_right = 8
		tabs[t].add_theme_stylebox_override("normal", style)

func _build_ses_tab(parent: Node):
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	parent.add_child(vbox)
	
	var settings = SaveManager.settings
	
	_add_slider(vbox, "Genel Ses", settings.get("master_volume", 1.0), func(val):
		SaveManager.settings["master_volume"] = val
		AudioServer.set_bus_volume_db(0, linear_to_db(val))
		SaveManager.save_game()
	)
	
	_add_slider(vbox, "Efekt Sesi", settings.get("sfx_volume", 1.0), func(val):
		SaveManager.settings["sfx_volume"] = val
		var bus = AudioServer.get_bus_index("SFX")
		print("SFX slider changed: val=", val, " bus=", bus, " volume=", linear_to_db(val))
		if bus >= 0:
			AudioServer.set_bus_volume_db(bus, linear_to_db(val))
			print("SFX bus volume after set: ", AudioServer.get_bus_volume_db(bus))
		SaveManager.save_game()
	)
	
	_add_slider(vbox, "Müzik", settings.get("music_volume", 1.0), func(val):
		SaveManager.settings["music_volume"] = val
		var bus = AudioServer.get_bus_index("Music")
		if bus >= 0:
			AudioServer.set_bus_volume_db(bus, linear_to_db(val))
		SaveManager.save_game()
	)

func _build_goruntu_tab(parent: Node):
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	parent.add_child(vbox)
	
	_add_toggle(vbox, "Tam Ekran", SaveManager.settings.get("fullscreen", false), func(val):
		SaveManager.settings["fullscreen"] = val
		if val:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		SaveManager.save_game()
	)

	
	# Çözünürlük seçimi
	var res_row = HBoxContainer.new()
	res_row.add_theme_constant_override("separation", 20)
	vbox.add_child(res_row)
	var res_label = Label.new()
	res_label.text = "Çözünürlük"
	res_label.custom_minimum_size = Vector2(200, 0)
	res_label.add_theme_color_override("font_color", Color.WHITE)
	res_label.add_theme_font_size_override("font_size", 18)
	res_row.add_child(res_label)
	var resolutions = [
		Vector2i(1920, 1080),
		Vector2i(1600, 900),
		Vector2i(1366, 768),
		Vector2i(1280, 720),
		Vector2i(1024, 768),
		Vector2i(800, 600),
	]
	var res_dropdown = OptionButton.new()
	res_dropdown.custom_minimum_size = Vector2(220, 40)
	var current_size = DisplayServer.window_get_size()
	for i in resolutions.size():
		var r = resolutions[i]
		res_dropdown.add_item("%d x %d" % [r.x, r.y])
		if current_size == r:
			res_dropdown.selected = i
	var res_list = resolutions
	res_dropdown.item_selected.connect(func(idx):
		var res = res_list[idx]
		DisplayServer.window_set_size(res)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		SaveManager.settings["fullscreen"] = false
		SaveManager.settings["resolution_x"] = res.x
		SaveManager.settings["resolution_y"] = res.y
		SaveManager.save_game()
	)
	res_row.add_child(res_dropdown)
	
	_add_toggle(vbox, "VFX Efektleri", SaveManager.settings.get("show_vfx", true), func(val):
		SaveManager.settings["show_vfx"] = val
		SaveManager.save_game()
	)

func _build_oynanis_tab(parent: Node):
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	parent.add_child(vbox)
	
	_add_dropdown(vbox, "Hasar Sayıları", SaveManager.settings.get("damage_numbers", "both_on"), func(val):
		SaveManager.settings["damage_numbers"] = val
		SaveManager.save_game()
	)
	
	_add_dropdown(vbox, "Can Barları", SaveManager.settings.get("hp_bars", "both_on"), func(val):
		SaveManager.settings["hp_bars"] = val
		SaveManager.save_game()
	)
	
	_add_toggle(vbox, "Ekran Sarsıntısı", SaveManager.settings.get("screen_shake", true), func(val):
		SaveManager.settings["screen_shake"] = val
		SaveManager.save_game()
	)

func _add_dropdown(parent: Node, label_text: String, current_val: String, callback: Callable):
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 20)
	parent.add_child(row)
	
	var label = Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(200, 0)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_font_size_override("font_size", 18)
	row.add_child(label)
	
	var options = ["both_on", "player_only", "enemy_only", "both_off"]
	var option_labels = ["İkisi de Açık", "Sadece Oyuncu", "Sadece Düşman", "İkisi de Kapalı"]
	
	var dropdown = OptionButton.new()
	dropdown.custom_minimum_size = Vector2(220, 40)
	for i in options.size():
		dropdown.add_item(option_labels[i])
	dropdown.selected = options.find(current_val)
	dropdown.item_selected.connect(func(idx): callback.call(options[idx]))
	row.add_child(dropdown)

func _add_slider(parent: Node, label_text: String, default_val: float, callback: Callable):
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 20)
	parent.add_child(row)
	
	var label = Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(200, 0)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_font_size_override("font_size", 18)
	row.add_child(label)
	
	var slider = HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = default_val
	slider.custom_minimum_size = Vector2(300, 40)
	slider.value_changed.connect(callback)
	row.add_child(slider)
	
	var percent = Label.new()
	percent.text = str(int(default_val * 100)) + "%"
	percent.custom_minimum_size = Vector2(60, 0)
	percent.add_theme_color_override("font_color", Color("#AAAAAA"))
	row.add_child(percent)
	
	slider.value_changed.connect(func(val):
		percent.text = str(int(val * 100)) + "%"
	)

func _add_toggle(parent: Node, label_text: String, default_val: bool, callback: Callable):
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 20)
	parent.add_child(row)
	
	var label = Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(200, 0)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_font_size_override("font_size", 18)
	row.add_child(label)
	
	var btn = CheckButton.new()
	btn.button_pressed = default_val
	btn.toggled.connect(callback)
	row.add_child(btn)

func _on_back():
	AudioManager.apply_volume_settings()
	var from_game = get_meta("from_game", false)
	if from_game:
		get_tree().paused = true
		var pause_menu = preload("res://ui/pause_menu.tscn").instantiate()
		pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS
		get_tree().root.add_child(pause_menu)
		queue_free()
	else:
		get_tree().change_scene_to_file("res://ui/main_menu.tscn")



func _build_profil_tab(parent: Node):
	var scroll = ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(0, 400)
	parent.add_child(scroll)
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(vbox)
	
	var stats = [
		["⚔ Toplam Öldürme", str(SaveManager.total_kills)],
		["💀 En İyi Koşu (Kill)", str(SaveManager.best_kill_run)],
		["🏆 Boss Öldürme", str(SaveManager.total_bosses_killed)],
		["🎮 Toplam Koşu", str(SaveManager.total_runs)],
		["🏅 Kazanılan Koşu", str(SaveManager.total_wins)],
		["💀 Toplam Ölüm", str(SaveManager.total_deaths)],
		["💰 Toplam Altın", str(SaveManager.total_gold_earned)],
		["⬆ Toplam Level", str(SaveManager.total_levels_gained)],
		["🗡 Toplam Hasar", str(SaveManager.total_damage_dealt)],
		["📦 Açılan Sandık", str(SaveManager.total_chests_opened)],
		["🛡 Toplanan Item", str(SaveManager.total_items_collected)],
		["⏱ En Uzun Hayatta Kalma", "%d:%02d" % [int(SaveManager.max_survival_time / 60), int(SaveManager.max_survival_time) % 60]],
	]
	
	for stat in stats:
		var row = HBoxContainer.new()
		vbox.add_child(row)
		var lbl = Label.new()
		lbl.text = stat[0]
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl.add_theme_color_override("font_color", Color("#AAAAAA"))
		row.add_child(lbl)
		var val = Label.new()
		val.text = stat[1]
		val.add_theme_color_override("font_color", Color("#FFFFFF"))
		row.add_child(val)

	# Achievement listesi
	var ach_title = Label.new()
	ach_title.text = "🏅 BAŞARIMLAR"
	ach_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ach_title.add_theme_font_size_override("font_size", 16)
	ach_title.add_theme_color_override("font_color", Color("#FFD700"))
	vbox.add_child(ach_title)
	
	var unlocked_count = 0
	for ach in AchievementData.ACHIEVEMENTS:
		var is_done = SaveManager.unlocked_achievements.has(ach["id"])
		if is_done:
			unlocked_count += 1
		var row = HBoxContainer.new()
		vbox.add_child(row)
		var icon_lbl = Label.new()
		icon_lbl.text = ach["icon"] if is_done else "🔒"
		row.add_child(icon_lbl)
		var name_lbl = Label.new()
		name_lbl.text = ach["name"]
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_lbl.add_theme_color_override("font_color", Color("#FFFFFF") if is_done else Color("#555555"))
		row.add_child(name_lbl)
		var reward_lbl = Label.new()
		reward_lbl.text = "+" + str(ach["reward_gold"]) + "💰" if is_done else "???"
		reward_lbl.add_theme_color_override("font_color", Color("#FFD700") if is_done else Color("#444444"))
		row.add_child(reward_lbl)
	
	var progress_lbl = Label.new()
	progress_lbl.text = "%d / %d tamamlandı" % [unlocked_count, AchievementData.ACHIEVEMENTS.size()]
	progress_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	progress_lbl.add_theme_color_override("font_color", Color("#9B59B6"))
	vbox.add_child(progress_lbl)

	# Ayırıcı
	var sep = HSeparator.new()
	vbox.add_child(sep)
	
	# Sıfırlama butonları
	var btn_stats = Button.new()
	btn_stats.text = "📊 İstatistikleri Sıfırla" if not _confirm_reset_stats else "⚠ Emin misin? Tekrar bas!"
	btn_stats.add_theme_color_override("font_color", Color("#E67E22"))
	btn_stats.pressed.connect(_on_reset_stats)
	vbox.add_child(btn_stats)
	
	var btn_full = Button.new()
	btn_full.text = "🗑 Tüm İlerlemeyi Sıfırla" if not _confirm_reset_full else "⚠ Emin misin? Tekrar bas!"
	btn_full.add_theme_color_override("font_color", Color("#E74C3C"))
	btn_full.pressed.connect(_on_reset_full)
	vbox.add_child(btn_full)

func _on_reset_stats():
	if not _confirm_reset_stats:
		_confirm_reset_stats = true
		_switch_tab("profil")
		return
	SaveManager.total_kills = 0
	SaveManager.best_kill_run = 0
	SaveManager.total_bosses_killed = 0
	SaveManager.total_runs = 0
	SaveManager.total_wins = 0
	SaveManager.total_deaths = 0
	SaveManager.total_gold_earned = 0
	SaveManager.total_levels_gained = 0
	SaveManager.total_damage_dealt = 0
	SaveManager.total_chests_opened = 0
	SaveManager.total_items_collected = 0
	SaveManager.max_survival_time = 0.0
	SaveManager.save_game()
	_confirm_reset_stats = false
	_switch_tab("profil")

func _on_reset_full():
	if not _confirm_reset_full:
		_confirm_reset_full = true
		_switch_tab("profil")
		return
	SaveManager.gold = 0
	SaveManager.selected_character = 0
	for key in SaveManager.meta_upgrades:
		SaveManager.meta_upgrades[key] = 0
	SaveManager.total_kills = 0
	SaveManager.best_kill_run = 0
	SaveManager.total_bosses_killed = 0
	SaveManager.total_runs = 0
	SaveManager.total_wins = 0
	SaveManager.total_deaths = 0
	SaveManager.total_gold_earned = 0
	SaveManager.total_levels_gained = 0
	SaveManager.total_damage_dealt = 0
	SaveManager.total_chests_opened = 0
	SaveManager.total_items_collected = 0
	SaveManager.max_survival_time = 0.0
	SaveManager.unlocked_characters = ["warrior", "mage", "vampire"]
	SaveManager.purchased_characters = ["warrior", "mage", "vampire"]
	SaveManager.save_game()
	_confirm_reset_full = false
	_switch_tab("profil")
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")

func _build_devtools_tab(parent: Node):
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	parent.add_child(vbox)
	
	var title = Label.new()
	title.text = "⚠ DEV TOOLS - Sadece Test İçin"
	title.add_theme_color_override("font_color", Color("#E74C3C"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	
	var sep = HSeparator.new()
	vbox.add_child(sep)
	
	# Gold ekle
	_add_dev_button(vbox, "💰 +1000 Gold Ekle", func():
		SaveManager.gold += 1000
		SaveManager.save_game()
		_switch_tab("devtools")
	)
	
	# Tüm meta upgrade maxla
	_add_dev_button(vbox, "⬆ Tüm Upgradeleri Maxla", func():
		for key in SaveManager.meta_upgrades:
			SaveManager.meta_upgrades[key] = 10
		SaveManager.save_game()
		_switch_tab("devtools")
	)
	
	# Tüm karakterleri aç
	_add_dev_button(vbox, "🔓 Tüm Karakterleri Aç", func():
		for char_data in CharacterData.CHARACTERS:
			var cid = char_data["id"]
			if not SaveManager.unlocked_characters.has(cid):
				SaveManager.unlocked_characters.append(cid)
			if not SaveManager.purchased_characters.has(cid):
				SaveManager.purchased_characters.append(cid)
		SaveManager.save_game()
		_switch_tab("devtools")
	)

	# Gold sıfırla
	_add_dev_button(vbox, "💸 Gold Sıfırla", func():
		SaveManager.gold = 0
		SaveManager.save_game()
		_switch_tab("devtools")
	)

	# Karakterleri kilitle (sıfırla)
	_add_dev_button(vbox, "🔒 Karakterleri Sıfırla", func():
		SaveManager.unlocked_characters = ["warrior", "mage", "vampire"]
		SaveManager.purchased_characters = ["warrior", "mage", "vampire"]
		SaveManager.save_game()
		_switch_tab("devtools")
	)
	
	var sep2 = HSeparator.new()
	vbox.add_child(sep2)
	
	var lbl = Label.new()
	lbl.text = "Mevcut Gold: " + str(SaveManager.gold)
	lbl.add_theme_color_override("font_color", Color("#FFD700"))
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lbl)

func _add_dev_button(parent: Node, text: String, callback: Callable):
	var btn = Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(0, 45)
	btn.pressed.connect(callback)
	parent.add_child(btn)
