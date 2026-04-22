extends CanvasLayer

var selected_index = -1
var _active_hero_class: String = ""
var _class_filter_buttons: Dictionary = {}
var _filter_accent: Color = Color("#9B59B6")

func _unhandled_input(event: InputEvent) -> void:
	if MenuInput.is_menu_back_pressed(event):
		get_viewport().set_input_as_handled()
		get_tree().change_scene_to_file("res://ui/game_mode_select.tscn")

func _ready():
	var main: VBoxContainer = $Panel/OuterMargin/MainVBox
	main.add_theme_constant_override("separation", 16)
	var title: Label = $Panel/OuterMargin/MainVBox/TitleLabel
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color("#9B59B6"))
	if SaveManager.game_mode == "local_coop":
		title.text = tr("ui.character_select.p1_title")
	else:
		title.text = tr("ui.character_select.title_solo")
	var grid: GridContainer = _grid()
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 16)
	var scroll: ScrollContainer = $Panel/OuterMargin/MainVBox/BodyHBox/LeftColumn/ScrollContainer
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	_setup_stats_panel_style()
	_setup_class_filter_row()
	build_characters()
	_update_gold_label()
	var action_row: HBoxContainer = $Panel/OuterMargin/MainVBox/ActionMargin/ActionRow
	action_row.get_node("BackButton").pressed.connect(_on_back)
	action_row.get_node("PlayButton").pressed.connect(_on_play)
	action_row.get_node("PlayButton").disabled = true
	var back_b: Button = action_row.get_node("BackButton") as Button
	var play_b: Button = action_row.get_node("PlayButton") as Button
	ButtonCoverStyles.apply(back_b, 0, 17, Vector4(18.0, 8.0, 18.0, 8.0))
	ButtonCoverStyles.apply(play_b, 1, 17, Vector4(18.0, 8.0, 18.0, 8.0))


func _grid() -> GridContainer:
	return $Panel/OuterMargin/MainVBox/BodyHBox/LeftColumn/ScrollContainer/GridCenterRow/GridContainer as GridContainer


func _stats_vbox() -> VBoxContainer:
	return $Panel/OuterMargin/MainVBox/BodyHBox/StatsColumn/StatsPanel/StatsScroll/StatsVBox as VBoxContainer


func _setup_stats_panel_style() -> void:
	var st := StyleBoxFlat.new()
	st.bg_color = Color(0.07, 0.08, 0.14)
	st.border_color = Color(0.22, 0.24, 0.34)
	st.set_border_width_all(1)
	st.corner_radius_top_left = 10
	st.corner_radius_top_right = 10
	st.corner_radius_bottom_left = 10
	st.corner_radius_bottom_right = 10
	var stats_panel: PanelContainer = $Panel/OuterMargin/MainVBox/BodyHBox/StatsColumn/StatsPanel
	stats_panel.add_theme_stylebox_override("panel", st)
	var stats_scroll: ScrollContainer = $Panel/OuterMargin/MainVBox/BodyHBox/StatsColumn/StatsPanel/StatsScroll
	stats_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	stats_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO


func _refresh_stats_panel() -> void:
	CharacterSelectStatsPanel.rebuild(_stats_vbox(), selected_index)

func _update_gold_label() -> void:
	$Panel/OuterMargin/MainVBox/GoldMargin/GoldLabel.text = "💰 " + str(SaveManager.gold)


func _play_button() -> Button:
	return $Panel/OuterMargin/MainVBox/ActionMargin/ActionRow/PlayButton as Button


func _setup_class_filter_row() -> void:
	var vbox: VBoxContainer = $Panel/OuterMargin/MainVBox
	if vbox.get_node_or_null("ClassFilterRow"):
		return
	var row = HBoxContainer.new()
	row.name = "ClassFilterRow"
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 10)
	var gold_margin: MarginContainer = vbox.get_node_or_null("GoldMargin")
	var insert_at: int = gold_margin.get_index() + 1 if gold_margin else 2
	vbox.add_child(row)
	vbox.move_child(row, insert_at)
	_class_filter_buttons.clear()
	var fv := 0
	for class_id in CharacterData.HERO_CLASS_FILTER_IDS:
		var btn = Button.new()
		btn.text = tr("ui.character_select.filter_%s" % class_id)
		btn.custom_minimum_size = Vector2(104, 36)
		btn.set_meta("filter_cover_variant", fv % 3)
		fv += 1
		var cid: String = class_id
		btn.pressed.connect(func(): _on_class_filter_pressed(cid))
		row.add_child(btn)
		_class_filter_buttons[cid] = btn
	_refresh_class_filter_buttons()

func _style_class_filter_button(btn: Button, active: bool) -> void:
	var v: int = int(btn.get_meta("filter_cover_variant", 0))
	var mod := Color(1.12, 1.02, 1.22, 1.0) if active else Color(0.62, 0.62, 0.68, 1.0)
	ButtonCoverStyles.apply(btn, v, 12, Vector4(8.0, 5.0, 8.0, 5.0), mod)

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
			_play_button().disabled = true
	build_characters()

func _character_visible_for_filter(_char_index: int, char_data: Dictionary) -> bool:
	if _active_hero_class.is_empty():
		return true
	return str(char_data.get("hero_class", "")) == _active_hero_class

func build_characters() -> void:
	var container: GridContainer = _grid()
	for child in container.get_children():
		child.queue_free()

	for i in CharacterData.CHARACTERS.size():
		var char_data = CharacterData.CHARACTERS[i]
		if not _character_visible_for_filter(i, char_data):
			continue
		var state = _get_state(char_data["id"])
		var card = _build_card(i, char_data, state)
		container.add_child(card)
	if selected_index >= 0:
		_update_selection_borders()
	_refresh_stats_panel()

func _get_state(char_id: String) -> String:
	if SaveManager.is_purchased(char_id):
		return "purchased"
	elif SaveManager.is_unlocked(char_id):
		return "unlocked"
	else:
		return "locked"

func _build_card(i: int, char_data: Dictionary, state: String) -> PanelContainer:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(188, 380)
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
	var char_visual: Control = null

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
			char_visual = CharacterSelectPreview.make_portrait(cid, "full", Color(char_data["color"]))
			name_label.text = CharacterSelectHelpers.character_display_name(cid)
			name_label.add_theme_color_override("font_color", Color(char_data["color"]))
			desc_label.text = CharacterSelectHelpers.rich_description_unlocked(char_data)
			desc_label.add_theme_color_override("font_color", Color("#B0B0B0"))

			var btn = _make_button(tr("ui.character_select.btn_select"), Color("#3498DB"), 0)
			var idx = i
			btn.pressed.connect(func(): _on_select(idx))
			vbox.add_child(char_visual)
			vbox.add_child(name_label)
			vbox.add_child(desc_label)
			vbox.add_child(btn)

		"unlocked":
			char_visual = CharacterSelectPreview.make_portrait(cid, "silhouette", Color(char_data["color"]))
			name_label.text = CharacterSelectHelpers.character_display_name(cid)
			name_label.add_theme_color_override("font_color", Color(char_data["color"]))
			desc_label.text = CharacterSelectHelpers.rich_description_unlocked(char_data)
			desc_label.add_theme_color_override("font_color", Color("#666666"))

			var cost = char_data["cost"]
			var can_afford = SaveManager.gold >= cost
			var buy_color = Color("#27AE60") if can_afford else Color("#7F8C8D")
			var btn = _make_button(tr("ui.character_select.btn_buy") % int(cost), buy_color, 2)
			btn.disabled = not can_afford
			btn.pressed.connect(func(): _on_purchase(cid))
			vbox.add_child(char_visual)
			vbox.add_child(name_label)
			vbox.add_child(desc_label)
			vbox.add_child(btn)

		"locked":
			char_visual = CharacterSelectPreview.make_portrait(cid, "locked", Color(char_data.get("color", "#444466")))
			name_label.text = "???" if char_data["secret"] else "🔒 " + CharacterSelectHelpers.character_display_name(cid)
			name_label.add_theme_color_override("font_color", Color("#444466"))
			desc_label.text = ""

			bottom.text = CharacterSelectHelpers.localized_unlock_hint(char_data)
			bottom.add_theme_color_override("font_color", Color("#555577"))
			vbox.add_child(char_visual)
			vbox.add_child(name_label)
			vbox.add_child(desc_label)
			vbox.add_child(bottom)

	card.add_child(vbox)
	return card

func _make_button(label_text: String, color: Color, cover_variant: int) -> Button:
	var btn = Button.new()
	btn.text = label_text
	btn.custom_minimum_size = Vector2(140, 50)
	var tint := Color.WHITE.lerp(color, 0.26)
	ButtonCoverStyles.apply(btn, cover_variant, 15, Vector4(12.0, 7.0, 12.0, 7.0), tint)
	btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	return btn

func _on_select(index: int) -> void:
	selected_index = index
	_update_selection_borders()
	_play_button().disabled = false
	_refresh_stats_panel()
	if SaveManager.game_mode == "local_coop":
		SaveManager.set_selected_character_p1_index(selected_index)
		SaveManager.save_game()
		get_tree().change_scene_to_file("res://ui/character_select_p2.tscn")

func _update_selection_borders() -> void:
	var container: GridContainer = _grid()
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

func _on_purchase(char_id: String):
	if SaveManager.purchase_character(char_id):
		build_characters()
		_update_gold_label()

func _on_play():
	if selected_index < 0:
		return
	SaveManager.set_selected_character_p1_index(selected_index)
	SaveManager.save_game()
	if SaveManager.game_mode == "local_coop":
		get_tree().change_scene_to_file("res://ui/character_select_p2.tscn")
	else:
		get_tree().change_scene_to_file("res://ui/map_select.tscn")

func _on_back():
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")
