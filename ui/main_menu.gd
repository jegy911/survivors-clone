extends CanvasLayer

## Oynat / meta / mağaza / kodeks / ayar / çıkış — `_build_ui` içinde `MenuRoot` altına yerleşir.
var _menu_root: Control
var _stats_line_label: Label
var _gold_line_label: Label


func _ready():
	if not LocalizationManager.locale_changed.is_connected(_refresh_ui):
		LocalizationManager.locale_changed.connect(_refresh_ui)
	_build_ui()


func _refresh_ui(_locale: String = "") -> void:
	_apply_texts()


func _apply_texts():
	if _stats_line_label and is_instance_valid(_stats_line_label):
		var wins := SaveManager.total_wins
		var runs := SaveManager.total_runs
		var kills := SaveManager.total_kills
		_stats_line_label.text = tr("ui.main_menu.stats") % [runs, kills, wins]
	if _gold_line_label and is_instance_valid(_gold_line_label):
		_gold_line_label.text = tr("ui.main_menu.gold") % SaveManager.gold

	var button_configs := _button_style_configs()
	for config in button_configs:
		var btn: Button = config[0]
		if btn == null or not is_instance_valid(btn):
			continue
		btn.text = config[1]
		var style := StyleBoxFlat.new()
		style.bg_color = config[3]
		style.border_color = config[2]
		style.border_width_left = 2
		style.border_width_right = 2
		style.border_width_top = 2
		style.border_width_bottom = 2
		style.corner_radius_top_left = 10
		style.corner_radius_top_right = 10
		style.corner_radius_bottom_left = 10
		style.corner_radius_bottom_right = 10
		btn.add_theme_stylebox_override("normal", style)
		var hover_style := style.duplicate()
		hover_style.bg_color = config[2]
		btn.add_theme_stylebox_override("hover", hover_style)


func _button_style_configs() -> Array:
	var root := get_node_or_null("MenuRoot")
	if root == null:
		return []
	return [
		[root.get_node_or_null("CenterColumn/StartButton"), tr("ui.main_menu.play"), Color("#27AE60"), Color("#1E8449")],
		[root.get_node_or_null("LeftColumn/UpgradeButton"), tr("ui.main_menu.meta"), Color("#8E44AD"), Color("#6C3483")],
		[root.get_node_or_null("LeftColumn/ShopButton"), tr("ui.main_menu.shop"), Color("#16A085"), Color("#117A65")],
		[root.get_node_or_null("RightColumn/CollectionButton"), tr("ui.main_menu.collection"), Color("#D68910"), Color("#B7950B")],
		[root.get_node_or_null("RightColumn/SettingsButton"), tr("ui.main_menu.settings"), Color("#2471A3"), Color("#1A5276")],
		[root.get_node_or_null("QuitButton"), tr("ui.main_menu.quit"), Color("#922B21"), Color("#7B241C")],
	]


func _apply_main_menu_background() -> void:
	var photo: TextureRect = $BackgroundPhoto
	var tint: ColorRect = $BackgroundTint
	photo.texture = null
	photo.visible = false
	tint.visible = false
	var tex: Texture2D = MainMenuBackground.load_texture()
	if tex != null:
		photo.texture = tex
		photo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		photo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		photo.visible = true
		tint.visible = true


func _build_ui() -> void:
	var screen_size: Vector2 = get_viewport().get_visible_rect().size

	_apply_main_menu_background()

	## Arka plan: referanstaki gibi net görünsün (hafif tint + hafif parlaklık).
	$BackgroundTint.color = Color(0.05, 0.05, 0.09, 0.16)
	var photo_rect := $BackgroundPhoto as TextureRect
	photo_rect.modulate = Color(1.14, 1.14, 1.1, 1.0)
	if photo_rect.visible:
		$StarsLayer.modulate = Color(1, 1, 1, 0.28)
	else:
		$StarsLayer.modulate = Color(1, 1, 1, 1.0)

	for c in $StarsLayer.get_children():
		c.queue_free()
	for i in 40:
		var star := ColorRect.new()
		star.size = Vector2(randf_range(1, 3), randf_range(1, 3))
		star.color = Color(1, 1, 1, randf_range(0.2, 0.8))
		star.position = Vector2(randf_range(0, screen_size.x), randf_range(0, screen_size.y))
		$StarsLayer.add_child(star)
		var st := star.create_tween()
		st.set_loops()
		st.tween_property(star, "modulate:a", 0.1, randf_range(1.0, 3.0))
		st.tween_property(star, "modulate:a", 1.0, randf_range(1.0, 3.0))

	var vb: VBoxContainer = $VBoxContainer
	var start_btn: Button = vb.get_node("StartButton")
	var upgrade_btn: Button = vb.get_node("UpgradeButton")
	var collection_btn: Button = vb.get_node("CollectionButton")
	var shop_btn: Button = vb.get_node("ShopButton")
	var settings_btn: Button = vb.get_node("SettingsButton")
	var quit_btn: Button = vb.get_node("QuitButton")

	## CanvasLayer üstünde anchor ile "tam ekran" genelde 0 boyut verir; kökü piksel boyutla sabitle.
	var menu := Control.new()
	menu.name = "MenuRoot"
	menu.set_anchors_preset(Control.PRESET_TOP_LEFT)
	menu.position = Vector2.ZERO
	menu.size = screen_size
	menu.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(menu)
	_menu_root = menu

	const BTN_W := 300.0
	const BTN_H := 56.0
	const COL_GAP := 18.0
	const PLAY_H := 64.0
	## Meta/Shop ve Codex/Settings sütunlarını dikey ortadan biraz aşağı.
	const SIDE_COLUMNS_NUDGE_Y := 80.0
	## Orta şerit + istatistik çubuğu genişliği (PLAY ile aynı hizada).
	var bar_w: float = minf(520.0, screen_size.x - 160.0)
	var center_w: float = maxf(bar_w, 400.0)
	var col_stack_h: float = BTN_H * 2.0 + COL_GAP
	var mid_y: float = screen_size.y * 0.42

	## Orta: PLAY tam yatay merkez + altta koyu yarı saydam istatistik şeridi
	var center := VBoxContainer.new()
	center.name = "CenterColumn"
	center.set_anchors_preset(Control.PRESET_TOP_LEFT)
	center.position = Vector2((screen_size.x - center_w) * 0.5, mid_y)
	center.custom_minimum_size = Vector2(center_w, 0.0)
	center.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_theme_constant_override("separation", 14)
	menu.add_child(center)

	start_btn.reparent(center)
	start_btn.set_anchors_preset(Control.PRESET_TOP_LEFT)
	start_btn.custom_minimum_size = Vector2(bar_w, PLAY_H)

	var stats_bar := PanelContainer.new()
	stats_bar.name = "StatsBar"
	stats_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stats_bar.custom_minimum_size = Vector2(bar_w, 72.0)
	var stats_style := StyleBoxFlat.new()
	stats_style.bg_color = Color(0.06, 0.07, 0.11, 0.78)
	stats_style.set_corner_radius_all(8)
	stats_style.content_margin_left = 14
	stats_style.content_margin_right = 14
	stats_style.content_margin_top = 10
	stats_style.content_margin_bottom = 10
	stats_bar.add_theme_stylebox_override("panel", stats_style)
	center.add_child(stats_bar)

	var stats_stack := VBoxContainer.new()
	stats_stack.name = "StatsStack"
	stats_stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stats_stack.alignment = BoxContainer.ALIGNMENT_CENTER
	stats_stack.add_theme_constant_override("separation", 6)
	stats_bar.add_child(stats_stack)

	_stats_line_label = Label.new()
	_stats_line_label.name = "StatsRunsKillsWinsLabel"
	_stats_line_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_stats_line_label.add_theme_font_size_override("font_size", 14)
	_stats_line_label.add_theme_color_override("font_color", Color(0.92, 0.94, 1.0, 1.0))
	_stats_line_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_stats_line_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stats_stack.add_child(_stats_line_label)

	_gold_line_label = Label.new()
	_gold_line_label.name = "StatsGoldLabel"
	_gold_line_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_gold_line_label.add_theme_font_size_override("font_size", 22)
	_gold_line_label.add_theme_color_override("font_color", Color("#FFD700"))
	_gold_line_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stats_stack.add_child(_gold_line_label)

	## Sol / sağ: ekranın ~%25 ve ~%75 merkezinde (kenara yapışık değil, ortaya simetrik)
	var left := VBoxContainer.new()
	left.name = "LeftColumn"
	left.set_anchors_preset(Control.PRESET_TOP_LEFT)
	left.position = Vector2(
		screen_size.x * 0.25 - BTN_W * 0.5,
		(screen_size.y - col_stack_h) * 0.5 + SIDE_COLUMNS_NUDGE_Y
	)
	left.custom_minimum_size = Vector2(BTN_W, 0.0)
	left.alignment = BoxContainer.ALIGNMENT_CENTER
	left.add_theme_constant_override("separation", COL_GAP)
	menu.add_child(left)

	upgrade_btn.reparent(left)
	shop_btn.reparent(left)
	upgrade_btn.set_anchors_preset(Control.PRESET_TOP_LEFT)
	shop_btn.set_anchors_preset(Control.PRESET_TOP_LEFT)
	upgrade_btn.custom_minimum_size = Vector2(BTN_W, BTN_H)
	shop_btn.custom_minimum_size = Vector2(BTN_W, BTN_H)

	## Sağ orta: Kodeks + Ayarlar
	var right := VBoxContainer.new()
	right.name = "RightColumn"
	right.set_anchors_preset(Control.PRESET_TOP_LEFT)
	right.position = Vector2(
		screen_size.x * 0.75 - BTN_W * 0.5,
		(screen_size.y - col_stack_h) * 0.5 + SIDE_COLUMNS_NUDGE_Y
	)
	right.custom_minimum_size = Vector2(BTN_W, 0.0)
	right.alignment = BoxContainer.ALIGNMENT_CENTER
	right.add_theme_constant_override("separation", COL_GAP)
	menu.add_child(right)

	collection_btn.reparent(right)
	settings_btn.reparent(right)
	collection_btn.set_anchors_preset(Control.PRESET_TOP_LEFT)
	settings_btn.set_anchors_preset(Control.PRESET_TOP_LEFT)
	collection_btn.custom_minimum_size = Vector2(BTN_W, BTN_H)
	settings_btn.custom_minimum_size = Vector2(BTN_W, BTN_H)

	## Çıkış: sol alt
	quit_btn.reparent(menu)
	quit_btn.set_anchors_preset(Control.PRESET_TOP_LEFT)
	quit_btn.position = Vector2(28.0, screen_size.y - 72.0)
	quit_btn.custom_minimum_size = Vector2(200, 52)
	quit_btn.size = Vector2(200, 52)

	vb.queue_free()

	if not AudioManager.music_player.playing:
		AudioManager.play_music(1)

	var button_configs := [
		[start_btn, tr("ui.main_menu.play"), Color("#27AE60"), Color("#1E8449")],
		[upgrade_btn, tr("ui.main_menu.meta"), Color("#8E44AD"), Color("#6C3483")],
		[collection_btn, tr("ui.main_menu.collection"), Color("#D68910"), Color("#B7950B")],
		[shop_btn, tr("ui.main_menu.shop"), Color("#16A085"), Color("#117A65")],
		[settings_btn, tr("ui.main_menu.settings"), Color("#2471A3"), Color("#1A5276")],
		[quit_btn, tr("ui.main_menu.quit"), Color("#922B21"), Color("#7B241C")],
	]

	for config in button_configs:
		var btn: Button = config[0]
		btn.text = config[1]
		var style := StyleBoxFlat.new()
		style.bg_color = config[3]
		style.border_color = config[2]
		style.border_width_left = 2
		style.border_width_right = 2
		style.border_width_top = 2
		style.border_width_bottom = 2
		style.corner_radius_top_left = 10
		style.corner_radius_top_right = 10
		style.corner_radius_bottom_left = 10
		style.corner_radius_bottom_right = 10
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_color_override("font_color", Color.WHITE)
		btn.add_theme_font_size_override("font_size", 20)
		var hover_style := style.duplicate()
		hover_style.bg_color = config[2]
		btn.add_theme_stylebox_override("hover", hover_style)

	start_btn.pressed.connect(_on_start)
	upgrade_btn.pressed.connect(_on_upgrades)
	collection_btn.pressed.connect(_on_collection)
	shop_btn.pressed.connect(_on_shop)
	settings_btn.pressed.connect(_on_settings)
	quit_btn.pressed.connect(_on_quit)

	_apply_texts()


func _on_start():
	get_tree().change_scene_to_file("res://ui/game_mode_select.tscn")


func _on_upgrades():
	get_tree().change_scene_to_file("res://ui/meta_upgrade.tscn")


func _on_collection():
	get_tree().change_scene_to_file("res://ui/collection_menu.tscn")


func _on_shop():
	get_tree().change_scene_to_file("res://ui/shop_menu.tscn")


func _on_settings():
	get_tree().change_scene_to_file("res://ui/settings.tscn")


func _on_quit():
	get_tree().quit()


var _easter_buffer := ""


func _input(event):
	if event is InputEventKey and event.pressed:
		var ch := OS.get_keycode_string(event.keycode).to_upper()
		if ch.length() == 1:
			_easter_buffer += ch
			if _easter_buffer.length() > 5:
				_easter_buffer = _easter_buffer.right(5)
			if _easter_buffer == "OMEGA":
				_try_unlock_omega()
				_easter_buffer = ""


func _try_unlock_omega():
	if SaveManager.unlocked_characters.has("omega"):
		return
	SaveManager.unlocked_characters.append("omega")
	SaveManager.save_game()
	var label := Label.new()
	label.text = tr("ui.main_menu.omega_unlock")
	label.add_theme_color_override("font_color", Color("#FF0000"))
	label.add_theme_font_size_override("font_size", 28)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_CENTER)
	var host: Node = get_node_or_null("MenuRoot")
	if host == null:
		host = self
	host.add_child(label)
	var tween := create_tween()
	tween.tween_property(label, "modulate:a", 0.0, 2.5)
	tween.tween_callback(label.queue_free)
