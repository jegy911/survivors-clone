extends CanvasLayer

var current_tab = "ses"
var _confirm_reset_full = false
var _confirm_reset_stats = false
var _dev_gold_amount = 1000
var _rebind_listen: bool = false
var _rebind_action: String = ""
var _rebind_btn: Button = null

func _ready():
	set_process_unhandled_input(false)
	var screen_size = get_viewport().get_visible_rect().size
	$Background.size = screen_size
	$Background.color = Color("#0D0D1A")

	if not LocalizationManager.locale_changed.is_connected(_on_locale_changed):
		LocalizationManager.locale_changed.connect(_on_locale_changed)

	_build_ui()


func _unhandled_input(event: InputEvent) -> void:
	if not _rebind_listen:
		return
	if event is InputEventKey and event.pressed and not event.is_echo():
		var e := event as InputEventKey
		if e.keycode == KEY_ESCAPE or e.physical_keycode == KEY_ESCAPE:
			_cancel_rebind()
			get_viewport().set_input_as_handled()
			return
		var pk: Key = e.physical_keycode
		if pk == KEY_NONE:
			pk = e.keycode
		if pk == KEY_NONE:
			return
		InputRemap.set_keyboard_binding(_rebind_action, pk)
		if _rebind_btn:
			_rebind_btn.text = InputRemap.get_keyboard_binding_display(_rebind_action)
		_rebind_listen = false
		_rebind_action = ""
		_rebind_btn = null
		set_process_unhandled_input(false)
		get_viewport().set_input_as_handled()


func _cancel_rebind() -> void:
	if _rebind_btn and _rebind_action != "":
		_rebind_btn.text = InputRemap.get_keyboard_binding_display(_rebind_action)
	_rebind_listen = false
	_rebind_action = ""
	_rebind_btn = null
	set_process_unhandled_input(false)


func _begin_rebind(action: String, btn: Button) -> void:
	if _rebind_listen:
		_cancel_rebind()
	_rebind_listen = true
	_rebind_action = action
	_rebind_btn = btn
	btn.text = tr("ui.settings.press_key")
	set_process_unhandled_input(true)


func _binding_locale_key(action: String) -> String:
	match action:
		"ui_up": return "ui.settings.bind_p1_up"
		"ui_down": return "ui.settings.bind_p1_down"
		"ui_left": return "ui.settings.bind_p1_left"
		"ui_right": return "ui.settings.bind_p1_right"
		"p2_up": return "ui.settings.bind_p2_up"
		"p2_down": return "ui.settings.bind_p2_down"
		"p2_left": return "ui.settings.bind_p2_left"
		"p2_right": return "ui.settings.bind_p2_right"
		"ui_cancel": return "ui.settings.bind_pause"
		"toggle_fullscreen": return "ui.settings.bind_fullscreen"
		_:
			return action

func _on_locale_changed(_locale: String) -> void:
	_refresh_chrome()
	_switch_tab(current_tab)

func _refresh_chrome() -> void:
	$VBoxContainer/TitleLabel.text = tr("ui.settings.title")
	SettingsUiStyles.style_tab_button($VBoxContainer/TabRow/SesTab, tr("ui.settings.tab_audio"))
	SettingsUiStyles.style_tab_button($VBoxContainer/TabRow/DilTab, tr("ui.settings.tab_language"))
	SettingsUiStyles.style_tab_button($VBoxContainer/TabRow/GoruntuTab, tr("ui.settings.tab_video"))
	SettingsUiStyles.style_tab_button($VBoxContainer/TabRow/OynanisTab, tr("ui.settings.tab_gameplay"))
	SettingsUiStyles.style_tab_button($VBoxContainer/TabRow/KontrolTab, tr("ui.settings.tab_controls"))
	SettingsUiStyles.style_tab_button($VBoxContainer/TabRow/ProfilTab, tr("ui.settings.tab_profile"))
	SettingsUiStyles.style_tab_button($VBoxContainer/TabRow/DevToolsTab, tr("ui.settings.tab_dev"))
	SettingsUiStyles.style_back_button($VBoxContainer/BackButton, tr("ui.settings.back_main"))

func _build_ui():
	var vbox = $VBoxContainer
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.alignment = BoxContainer.ALIGNMENT_BEGIN
	vbox.add_theme_constant_override("separation", 0)

	$VBoxContainer/TitleLabel.text = tr("ui.settings.title")
	$VBoxContainer/TitleLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$VBoxContainer/TitleLabel.add_theme_font_size_override("font_size", 36)
	$VBoxContainer/TitleLabel.add_theme_color_override("font_color", Color("#9B59B6"))

	SettingsUiStyles.style_tab_button($VBoxContainer/TabRow/SesTab, tr("ui.settings.tab_audio"))
	SettingsUiStyles.style_tab_button($VBoxContainer/TabRow/DilTab, tr("ui.settings.tab_language"))
	SettingsUiStyles.style_tab_button($VBoxContainer/TabRow/GoruntuTab, tr("ui.settings.tab_video"))
	SettingsUiStyles.style_tab_button($VBoxContainer/TabRow/OynanisTab, tr("ui.settings.tab_gameplay"))
	SettingsUiStyles.style_tab_button($VBoxContainer/TabRow/KontrolTab, tr("ui.settings.tab_controls"))
	SettingsUiStyles.style_tab_button($VBoxContainer/TabRow/ProfilTab, tr("ui.settings.tab_profile"))
	SettingsUiStyles.style_tab_button($VBoxContainer/TabRow/DevToolsTab, tr("ui.settings.tab_dev"))

	$VBoxContainer/TabRow/DevToolsTab.pressed.connect(func(): _switch_tab("devtools"))
	$VBoxContainer/TabRow/SesTab.pressed.connect(func(): _switch_tab("ses"))
	$VBoxContainer/TabRow/DilTab.pressed.connect(func(): _switch_tab("dil"))
	$VBoxContainer/TabRow/GoruntuTab.pressed.connect(func(): _switch_tab("goruntu"))
	$VBoxContainer/TabRow/OynanisTab.pressed.connect(func(): _switch_tab("oynanis"))
	$VBoxContainer/TabRow/KontrolTab.pressed.connect(func(): _switch_tab("kontrol"))
	$VBoxContainer/TabRow/ProfilTab.pressed.connect(func(): _switch_tab("profil"))

	SettingsUiStyles.style_back_button($VBoxContainer/BackButton, tr("ui.settings.back_main"))
	$VBoxContainer/BackButton.pressed.connect(_on_back)

	_switch_tab("ses")

func _switch_tab(tab: String):
	if _rebind_listen:
		_cancel_rebind()
	current_tab = tab
	var content = $VBoxContainer/ContentArea
	for child in content.get_children():
		child.queue_free()

	match tab:
		"ses": _build_ses_tab(content)
		"dil": _build_dil_tab(content)
		"goruntu": _build_goruntu_tab(content)
		"oynanis": _build_oynanis_tab(content)
		"kontrol": _build_kontrol_tab(content)
		"profil": _build_profil_tab(content)
		"devtools": _build_devtools_tab(content)

	var tabs = {
		"ses": $VBoxContainer/TabRow/SesTab,
		"dil": $VBoxContainer/TabRow/DilTab,
		"goruntu": $VBoxContainer/TabRow/GoruntuTab,
		"oynanis": $VBoxContainer/TabRow/OynanisTab,
		"kontrol": $VBoxContainer/TabRow/KontrolTab,
		"profil": $VBoxContainer/TabRow/ProfilTab,
		"devtools": $VBoxContainer/TabRow/DevToolsTab,
	}
	for t in tabs:
		var style = StyleBoxFlat.new()
		style.bg_color = Color("#9B59B6") if t == tab else Color("#1A1A2E")
		style.corner_radius_top_left = 8
		style.corner_radius_top_right = 8
		tabs[t].add_theme_stylebox_override("normal", style)

func _build_dil_tab(parent: Node):
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 24)
	parent.add_child(vbox)

	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 20)
	vbox.add_child(row)

	var lab = Label.new()
	lab.text = tr("ui.settings.language_label")
	lab.custom_minimum_size = Vector2(220, 0)
	lab.add_theme_color_override("font_color", Color.WHITE)
	lab.add_theme_font_size_override("font_size", 18)
	row.add_child(lab)

	var locales: Array[String] = []
	var ob = OptionButton.new()
	ob.custom_minimum_size = Vector2(240, 40)
	for entry in LocalizationManager.LANGUAGE_CATALOG:
		var code: String = str(entry["code"])
		locales.append(code)
		ob.add_item(tr(str(entry["label_key"])))
	var cur: String = str(SaveManager.settings.get("locale", "en"))
	ob.selected = locales.find(cur) if locales.has(cur) else 0
	ob.item_selected.connect(func(idx: int):
		LocalizationManager.set_locale(locales[idx])
	)
	row.add_child(ob)

func _build_ses_tab(parent: Node):
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	parent.add_child(vbox)

	var settings = SaveManager.settings

	_add_slider(vbox, tr("ui.settings.master"), settings.get("master_volume", 1.0), func(val):
		SaveManager.settings["master_volume"] = val
		AudioServer.set_bus_volume_db(0, linear_to_db(val))
		SaveManager.save_game()
	)

	_add_slider(vbox, tr("ui.settings.sfx"), settings.get("sfx_volume", 1.0), func(val):
		SaveManager.settings["sfx_volume"] = val
		var bus = AudioServer.get_bus_index("SFX")
		if bus >= 0:
			AudioServer.set_bus_volume_db(bus, linear_to_db(val))
		SaveManager.save_game()
	)

	_add_slider(vbox, tr("ui.settings.music"), settings.get("music_volume", 1.0), func(val):
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

	_add_toggle(vbox, tr("ui.settings.fullscreen"), SaveManager.settings.get("fullscreen", false), func(val):
		SaveManager.settings["fullscreen"] = val
		SaveManager.apply_window_mode_from_settings()
		SaveManager.save_game()
	)

	var res_row = HBoxContainer.new()
	res_row.add_theme_constant_override("separation", 20)
	vbox.add_child(res_row)
	var res_label = Label.new()
	res_label.text = tr("ui.settings.resolution")
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

	_add_toggle(vbox, tr("ui.settings.vfx"), SaveManager.settings.get("show_vfx", true), func(val):
		SaveManager.settings["show_vfx"] = val
		SaveManager.save_game()
	)

	_add_performance_quality_row(vbox)

	_add_ui_scale_slider_row(vbox)
	_add_colorblind_dropdown_row(vbox)

	_add_toggle(vbox, tr("ui.settings.enemy_high_contrast_outline"), SaveManager.settings.get("enemy_high_contrast_outline", false), func(val):
		SaveManager.settings["enemy_high_contrast_outline"] = val
		SaveManager.save_game()
	)

func _build_oynanis_tab(parent: Node):
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	parent.add_child(vbox)

	_add_dropdown(vbox, tr("ui.settings.damage_numbers"), SaveManager.settings.get("damage_numbers", "both_on"), func(val):
		SaveManager.settings["damage_numbers"] = val
		SaveManager.save_game()
	)

	_add_dropdown(vbox, tr("ui.settings.hp_bars"), SaveManager.settings.get("hp_bars", "both_on"), func(val):
		SaveManager.settings["hp_bars"] = val
		SaveManager.save_game()
	)

	_add_toggle(vbox, tr("ui.settings.screen_shake"), SaveManager.settings.get("screen_shake", true), func(val):
		SaveManager.settings["screen_shake"] = val
		SaveManager.save_game()
	)

	_add_toggle(vbox, tr("ui.settings.pause_on_focus_loss"), SaveManager.settings.get("pause_on_focus_loss", true), func(val):
		SaveManager.settings["pause_on_focus_loss"] = val
		SaveManager.save_game()
	)

	_add_slider(vbox, tr("ui.settings.player_vfx_opacity"), SaveManager.settings.get("player_vfx_opacity", 1.0), func(val):
		SaveManager.settings["player_vfx_opacity"] = val
		SaveManager.save_game()
	)

func _build_kontrol_tab(parent: Node) -> void:
	var outer := VBoxContainer.new()
	outer.add_theme_constant_override("separation", 12)
	parent.add_child(outer)

	var hint := Label.new()
	hint.text = tr("ui.settings.controls_hint")
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_color_override("font_color", Color("#AAAAAA"))
	hint.add_theme_font_size_override("font_size", 15)
	outer.add_child(hint)

	var reset_btn := Button.new()
	reset_btn.text = tr("ui.settings.reset_keybindings")
	reset_btn.pressed.connect(func():
		InputRemap.reset_to_defaults_and_save()
		_switch_tab("kontrol")
	)
	outer.add_child(reset_btn)

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 360)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	outer.add_child(scroll)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(vbox)

	for action in InputRemap.REMAPPABLE_ACTIONS:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 16)
		vbox.add_child(row)
		var lab := Label.new()
		lab.text = tr(_binding_locale_key(action))
		lab.custom_minimum_size = Vector2(260, 0)
		lab.add_theme_color_override("font_color", Color.WHITE)
		lab.add_theme_font_size_override("font_size", 17)
		row.add_child(lab)
		var bind_btn := Button.new()
		bind_btn.custom_minimum_size = Vector2(200, 44)
		bind_btn.text = InputRemap.get_keyboard_binding_display(action)
		var a := action
		bind_btn.pressed.connect(func(): _begin_rebind(a, bind_btn))
		row.add_child(bind_btn)

	var pad_hint := Label.new()
	pad_hint.text = tr("ui.settings.gamepad_hint")
	pad_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	pad_hint.add_theme_color_override("font_color", Color("#666688"))
	pad_hint.add_theme_font_size_override("font_size", 14)
	outer.add_child(pad_hint)

func _add_performance_quality_row(parent: Node) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 20)
	parent.add_child(row)
	var label := Label.new()
	label.text = tr("ui.settings.performance_quality")
	label.custom_minimum_size = Vector2(200, 0)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_font_size_override("font_size", 18)
	row.add_child(label)
	var options: Array[String] = ["high", "medium", "low"]
	var keys: Array[String] = ["perf_quality_high", "perf_quality_medium", "perf_quality_low"]
	var dropdown := OptionButton.new()
	dropdown.custom_minimum_size = Vector2(220, 40)
	for i in options.size():
		dropdown.add_item(tr("ui.settings." + keys[i]))
	var cur: String = str(SaveManager.settings.get("performance_quality", "high"))
	dropdown.selected = options.find(cur) if options.has(cur) else 0
	dropdown.item_selected.connect(func(idx: int):
		SaveManager.settings["performance_quality"] = options[idx]
		SaveManager.save_game()
	)
	row.add_child(dropdown)

func _add_ui_scale_slider_row(parent: Node) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 20)
	parent.add_child(row)
	var lab := Label.new()
	lab.text = tr("ui.settings.ui_text_scale")
	lab.custom_minimum_size = Vector2(200, 0)
	lab.add_theme_color_override("font_color", Color.WHITE)
	lab.add_theme_font_size_override("font_size", 18)
	row.add_child(lab)
	var slider := HSlider.new()
	slider.min_value = 0.82
	slider.max_value = 1.38
	slider.step = 0.02
	var cur: float = SaveManager.get_ui_scale()
	slider.value = cur
	slider.custom_minimum_size = Vector2(300, 40)
	row.add_child(slider)
	var pct := Label.new()
	pct.custom_minimum_size = Vector2(56, 0)
	pct.add_theme_color_override("font_color", Color("#AAAAAA"))
	pct.text = str(int(round(cur * 100))) + "%"
	row.add_child(pct)
	slider.value_changed.connect(func(v: float):
		SaveManager.settings["ui_scale"] = v
		SaveManager.save_game()
		pct.text = str(int(round(v * 100))) + "%"
	)

func _add_colorblind_dropdown_row(parent: Node) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 20)
	parent.add_child(row)
	var lab := Label.new()
	lab.text = tr("ui.settings.colorblind_palette")
	lab.custom_minimum_size = Vector2(200, 0)
	lab.add_theme_color_override("font_color", Color.WHITE)
	lab.add_theme_font_size_override("font_size", 18)
	row.add_child(lab)
	var modes: Array[String] = ["none", "friendly"]
	var ob := OptionButton.new()
	ob.custom_minimum_size = Vector2(240, 40)
	ob.add_item(tr("ui.settings.colorblind_none"))
	ob.add_item(tr("ui.settings.colorblind_friendly"))
	var cm := SaveManager.get_colorblind_mode()
	ob.selected = 1 if cm == "friendly" else 0
	ob.item_selected.connect(func(idx: int):
		SaveManager.settings["colorblind_palette"] = modes[idx]
		SaveManager.save_game()
	)
	row.add_child(ob)

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
	var option_keys = ["option_both_on", "option_player_only", "option_enemy_only", "option_both_off"]

	var dropdown = OptionButton.new()
	dropdown.custom_minimum_size = Vector2(220, 40)
	for i in options.size():
		dropdown.add_item(tr("ui.settings." + option_keys[i]))
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
	var stats_title = Label.new()
	stats_title.text = tr("ui.settings.stats_title")
	stats_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_title.add_theme_font_size_override("font_size", 16)
	stats_title.add_theme_color_override("font_color", Color("#FFD700"))
	vbox.add_child(stats_title)

	var stat_keys = [
		"total_kills", "best_kill_run", "boss_kills", "total_runs", "total_wins", "total_deaths",
		"total_gold", "total_levels", "total_damage", "chests", "items", "survival",
	]
	var stat_values = [
		str(SaveManager.total_kills),
		str(SaveManager.best_kill_run),
		str(SaveManager.total_bosses_killed),
		str(SaveManager.total_runs),
		str(SaveManager.total_wins),
		str(SaveManager.total_deaths),
		str(SaveManager.total_gold_earned),
		str(SaveManager.total_levels_gained),
		str(SaveManager.total_damage_dealt),
		str(SaveManager.total_chests_opened),
		str(SaveManager.total_items_collected),
		"%d:%02d" % [int(SaveManager.max_survival_time / 60), int(SaveManager.max_survival_time) % 60],
	]
	for i in stat_keys.size():
		var row = HBoxContainer.new()
		vbox.add_child(row)
		var lbl = Label.new()
		lbl.text = tr("ui.stats." + stat_keys[i])
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl.add_theme_color_override("font_color", Color("#AAAAAA"))
		row.add_child(lbl)
		var val = Label.new()
		val.text = stat_values[i]
		val.add_theme_color_override("font_color", Color("#FFFFFF"))
		row.add_child(val)

	var ach_title = Label.new()
	ach_title.text = tr("ui.settings.achievements_title")
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
		name_lbl.text = tr("achievement." + ach["id"] + ".name")
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_lbl.add_theme_color_override("font_color", Color("#FFFFFF") if is_done else Color("#555555"))
		row.add_child(name_lbl)
		var reward_lbl = Label.new()
		reward_lbl.text = "+" + str(ach["reward_gold"]) + "💰" if is_done else "???"
		reward_lbl.add_theme_color_override("font_color", Color("#FFD700") if is_done else Color("#444444"))
		row.add_child(reward_lbl)

	var progress_lbl = Label.new()
	progress_lbl.text = tr("ui.settings.ach_progress") % [unlocked_count, AchievementData.ACHIEVEMENTS.size()]
	progress_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	progress_lbl.add_theme_color_override("font_color", Color("#9B59B6"))
	vbox.add_child(progress_lbl)

	var sep = HSeparator.new()
	vbox.add_child(sep)

	var btn_stats = Button.new()
	btn_stats.text = tr("ui.settings.reset_stats_confirm") if _confirm_reset_stats else tr("ui.settings.reset_stats")
	btn_stats.add_theme_color_override("font_color", Color("#E67E22"))
	btn_stats.pressed.connect(_on_reset_stats)
	vbox.add_child(btn_stats)

	var btn_full = Button.new()
	btn_full.text = tr("ui.settings.reset_full_confirm") if _confirm_reset_full else tr("ui.settings.reset_full")
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
	SaveManager.unlocked_achievements = []
	SaveManager.save_game()
	_confirm_reset_stats = false
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")

func _on_reset_full():
	if not _confirm_reset_full:
		_confirm_reset_full = true
		_switch_tab("profil")
		return
	SaveManager.gold = 0
	SaveManager.selected_character = 0
	SaveManager.selected_character_p2 = 0
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
	SaveManager.unlocked_characters = ["warrior"]
	SaveManager.purchased_characters = ["warrior"]
	SaveManager.unlocked_achievements = []
	SaveManager.codex_discovered = []
	SaveManager.codex_weapons = []
	SaveManager.codex_items = []
	SaveManager.codex_maps = []
	InputRemap.reset_to_defaults_and_save()
	SaveManager.save_game()
	_confirm_reset_full = false
	_switch_tab("profil")
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")

func _build_devtools_tab(parent: Node):
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	parent.add_child(vbox)

	var title = Label.new()
	title.text = tr("ui.settings.dev_title")
	title.add_theme_color_override("font_color", Color("#E74C3C"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var sep = HSeparator.new()
	vbox.add_child(sep)

	_add_dev_button(vbox, tr("ui.devtools.add_gold"), func():
		SaveManager.gold += 1000
		SaveManager.save_game()
		_switch_tab("devtools")
	)

	_add_dev_button(vbox, tr("ui.devtools.max_meta"), func():
		for key in SaveManager.meta_upgrades:
			SaveManager.meta_upgrades[key] = 10
		SaveManager.save_game()
		_switch_tab("devtools")
	)

	_add_dev_button(vbox, tr("ui.devtools.unlock_chars"), func():
		for char_data in CharacterData.CHARACTERS:
			var cid = char_data["id"]
			if not SaveManager.unlocked_characters.has(cid):
				SaveManager.unlocked_characters.append(cid)
			if not SaveManager.purchased_characters.has(cid):
				SaveManager.purchased_characters.append(cid)
		SaveManager.save_game()
		_switch_tab("devtools")
	)

	_add_dev_button(vbox, tr("ui.devtools.gold_zero"), func():
		SaveManager.gold = 0
		SaveManager.save_game()
		_switch_tab("devtools")
	)

	_add_dev_button(vbox, tr("ui.devtools.lock_chars"), func():
		SaveManager.unlocked_characters = ["warrior"]
		SaveManager.purchased_characters = ["warrior"]
		SaveManager.save_game()
		_switch_tab("devtools")
	)

	var sep2 = HSeparator.new()
	vbox.add_child(sep2)

	var lbl = Label.new()
	lbl.text = tr("ui.settings.dev_gold") % SaveManager.gold
	lbl.add_theme_color_override("font_color", Color("#FFD700"))
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lbl)

func _add_dev_button(parent: Node, text: String, callback: Callable):
	var btn = Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(0, 45)
	btn.pressed.connect(callback)
	parent.add_child(btn)
