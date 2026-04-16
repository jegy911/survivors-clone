extends CanvasLayer

signal upgrade_chosen(upgrade_id)

const WEAPON_UPGRADE_IDS: Array[String] = [
	"bullet", "dagger", "aura", "chain", "boomerang", "lightning", "ice_ball", "shadow", "laser", "fan_blade",
	"hex_sigil", "gravity_anchor", "bastion_flail", "shield_ram",
]
const ITEM_UPGRADE_IDS: Array[String] = [
	"lifesteal", "armor", "crit", "explosion", "magnet", "poison", "shield", "speed_charm", "blood_pool",
	"luck_stone", "turbine", "steam_armor", "energy_cell", "ember_heart", "glyph_charm", "resonance_stone",
	"rampart_plate", "iron_bulwark", "night_vial",
]
const STAT_UPGRADES: Array[String] = ["speed", "max_hp", "heal"]

const _HEADER_GREEN := Color("2d4c3b")
const _PANEL_BG := Color(0.06, 0.06, 0.1, 0.92)
const _SLOT_BG := Color(0.12, 0.12, 0.16, 1.0)
const _SLOT_LOCKED := Color(0.08, 0.08, 0.1, 1.0)
const _ACCENT := Color("c8f7c5")
const _GOLD := Color("f5d742")
const _RARITY_COMMON := Color("9aa0a6")
const _RARITY_UNCOMMON := Color("6ab0ff")
const _RARITY_RARE := Color("c07cff")
const _RARITY_EVO := Color("ffd700")

const _WEAPON_GLYPH: Dictionary = {
	"bullet": "◎", "dagger": "🗡", "aura": "◇", "chain": "⛓", "boomerang": "↺", "lightning": "⚡",
	"ice_ball": "❄", "shadow": "▓", "laser": "╾", "fan_blade": "✦", "hex_sigil": "⬡",
	"gravity_anchor": "◎", "bastion_flail": "⛓", "shield_ram": "▶", "holy_bullet": "✧",
	"toxic_chain": "☠", "death_laser": "☇", "blood_boomerang": "🩸", "storm": "🌩",
	"shadow_storm": "🌑", "frost_nova": "❅", "ember_fan": "🔥", "binding_circle": "⭕",
	"void_lens": "◉", "citadel_flail": "⚔", "fortress_ram": "🛡", "veil_daggers": "🗡",
}

const _ITEM_GLYPH: Dictionary = {
	"lifesteal": "♥", "armor": "🛡", "crit": "✴", "explosion": "💥", "magnet": "🧲", "poison": "☠",
	"shield": "◇", "speed_charm": "👟", "blood_pool": "🩸", "luck_stone": "🍀", "turbine": "⚙",
	"steam_armor": "♨", "energy_cell": "🔋", "ember_heart": "🔥", "glyph_charm": "✧",
	"resonance_stone": "◇", "rampart_plate": "🧱", "iron_bulwark": "⛨", "night_vial": "🌙",
}

var player_ref: Node = null
var current_pool: Array = []
var chosen_upgrades: Array = []

var reroll_count: int = 2
var skip_count: int = 2
var pick_count: int = 3

var _root: Control
var _outer_margin: MarginContainer
var _title: Label
var _columns: HBoxContainer
var _weapons_grid: GridContainer
var _items_grid: GridContainer
var _options_column: VBoxContainer
var _stats_scroll: ScrollContainer
var _stats_vbox: VBoxContainer
var _reroll_btn: Button
var _skip_btn: Button
var _card_nodes: Array[Control] = []
var _hovered_card: Control = null
var _uses_editor_scene: bool = false


func _option_buttons() -> Array:
	return _card_nodes


func _layout_levelup_panel(n_options: int) -> void:
	pick_count = n_options
	for c in _card_nodes:
		c.visible = false
	for i in mini(n_options, _card_nodes.size()):
		_card_nodes[i].visible = true


func _style_flat_panel(bg: Color, border: Color = Color(0.5, 0.55, 0.6, 0.85), width: int = 1) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(width)
	s.corner_radius_top_left = 6
	s.corner_radius_top_right = 6
	s.corner_radius_bottom_left = 6
	s.corner_radius_bottom_right = 6
	return s


func _populate_icon_wrap(icon_wrap: PanelContainer, tex: Texture2D, glyph: String, font_size: int = 22) -> void:
	for ch in icon_wrap.get_children():
		ch.queue_free()
	if tex != null:
		var tr_icon := TextureRect.new()
		tr_icon.texture = tex
		tr_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tr_icon.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tr_icon.size_flags_vertical = Control.SIZE_EXPAND_FILL
		icon_wrap.add_child(tr_icon)
	else:
		var lab := Label.new()
		lab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lab.size_flags_vertical = Control.SIZE_EXPAND_FILL
		lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lab.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lab.text = glyph
		lab.add_theme_font_size_override("font_size", font_size)
		lab.add_theme_color_override("font_color", Color.WHITE)
		icon_wrap.add_child(lab)


func _texture_for_upgrade_card(id: String, is_evo: bool) -> Texture2D:
	if is_evo or WeaponEvolution.EVOLUTIONS.has(id):
		return UpgradeIconCatalog.try_evolution(id)
	if id in WEAPON_UPGRADE_IDS:
		return UpgradeIconCatalog.try_weapon(id)
	if id in ITEM_UPGRADE_IDS:
		return UpgradeIconCatalog.try_item(id)
	if id in STAT_UPGRADES:
		return UpgradeIconCatalog.try_stat(id)
	return null


func _style_header() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = _HEADER_GREEN
	s.border_color = Color(0.55, 0.65, 0.55, 0.9)
	s.set_border_width_all(1)
	s.corner_radius_top_left = 4
	s.corner_radius_top_right = 4
	return s


func _ready() -> void:
	layer = 120
	process_mode = Node.PROCESS_MODE_ALWAYS
	var editor_root: Node = get_node_or_null("EditorRoot")
	if editor_root is Control:
		_uses_editor_scene = true
		_bind_editor_root(editor_root as Control)
	else:
		_build_ui_shell()
	_apply_action_tooltips()
	_apply_ui_scale()


func _bind_editor_root(editor: Control) -> void:
	_root = editor
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	_outer_margin = editor.get_node("OuterMargin") as MarginContainer
	_title = editor.get_node("OuterMargin/OuterVBox/TitleLabel") as Label
	_columns = editor.get_node("OuterMargin/OuterVBox/ColumnsHBox") as HBoxContainer
	_weapons_grid = editor.get_node("OuterMargin/OuterVBox/ColumnsHBox/LeftColumn/InvPanel/InvVBox/WeaponsGrid") as GridContainer
	_items_grid = editor.get_node("OuterMargin/OuterVBox/ColumnsHBox/LeftColumn/InvPanel/InvVBox/ItemsGrid") as GridContainer
	_options_column = editor.get_node("OuterMargin/OuterVBox/ColumnsHBox/CenterColumn/OptionsScroll/OptionsVBox") as VBoxContainer
	_reroll_btn = editor.get_node("OuterMargin/OuterVBox/ColumnsHBox/CenterColumn/ActionRow/RerollButton") as Button
	_skip_btn = editor.get_node("OuterMargin/OuterVBox/ColumnsHBox/CenterColumn/ActionRow/SkipButton") as Button
	_stats_scroll = editor.get_node("OuterMargin/OuterVBox/ColumnsHBox/RightColumn/StatsPanel/StatsScroll") as ScrollContainer
	_stats_vbox = editor.get_node("OuterMargin/OuterVBox/ColumnsHBox/RightColumn/StatsPanel/StatsScroll/StatsVBox") as VBoxContainer
	_card_nodes.clear()
	for i in 4:
		var card: PanelContainer = editor.get_node("OuterMargin/OuterVBox/ColumnsHBox/CenterColumn/OptionsScroll/OptionsVBox/UpgradeCard%d" % i) as PanelContainer
		_wire_upgrade_card(card, i)
		_card_nodes.append(card)
	if not _reroll_btn.pressed.is_connected(_on_reroll):
		_reroll_btn.pressed.connect(_on_reroll)
	if not _skip_btn.pressed.is_connected(_on_skip):
		_skip_btn.pressed.connect(_on_skip)
	_editor_refresh_static_labels()
	_editor_apply_shell_styles()


func _editor_refresh_static_labels() -> void:
	var inv_h: Label = _root.get_node_or_null("OuterMargin/OuterVBox/ColumnsHBox/LeftColumn/InvPanel/InvVBox/InvHeaderLabel") as Label
	if inv_h:
		inv_h.text = tr("ui.upgrade_ui.panel_inventory")
	var up_h: Label = _root.get_node_or_null("OuterMargin/OuterVBox/ColumnsHBox/CenterColumn/UpgradesHeaderLabel") as Label
	if up_h:
		up_h.text = tr("ui.upgrade_ui.panel_upgrades")
	var st_h: Label = _root.get_node_or_null("OuterMargin/OuterVBox/ColumnsHBox/RightColumn/StatsHeaderLabel") as Label
	if st_h:
		st_h.text = tr("ui.upgrade_ui.panel_stats")
	var wl: Label = _root.get_node_or_null("OuterMargin/OuterVBox/ColumnsHBox/LeftColumn/InvPanel/InvVBox/WeaponsHeaderLabel") as Label
	if wl:
		wl.text = tr("ui.upgrade_ui.weapons_header")
	var il: Label = _root.get_node_or_null("OuterMargin/OuterVBox/ColumnsHBox/LeftColumn/InvPanel/InvVBox/ItemsHeaderLabel") as Label
	if il:
		il.text = tr("ui.upgrade_ui.items_header")


func _editor_apply_shell_styles() -> void:
	var inv_panel: PanelContainer = _root.get_node("OuterMargin/OuterVBox/ColumnsHBox/LeftColumn/InvPanel") as PanelContainer
	inv_panel.add_theme_stylebox_override("panel", _style_flat_panel(_PANEL_BG))
	var stats_panel: PanelContainer = _root.get_node("OuterMargin/OuterVBox/ColumnsHBox/RightColumn/StatsPanel") as PanelContainer
	stats_panel.add_theme_stylebox_override("panel", _style_flat_panel(_PANEL_BG))
	for i in 4:
		var c: PanelContainer = _card_nodes[i] as PanelContainer
		c.add_theme_stylebox_override("panel", _style_flat_panel(Color(0.11, 0.12, 0.18), Color(0.65, 0.7, 0.75), 1))
		var iw: PanelContainer = c.get_meta("icon_wrap") as PanelContainer
		iw.add_theme_stylebox_override("panel", _style_flat_panel(_SLOT_BG, Color(0.4, 0.45, 0.5), 1))
	var rb: StyleBoxFlat = _style_flat_panel(Color(0.1, 0.12, 0.2))
	_reroll_btn.add_theme_stylebox_override("normal", rb)
	_skip_btn.add_theme_stylebox_override("normal", rb)


func _wire_upgrade_card(panel: PanelContainer, index: int) -> void:
	panel.visible = false
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.custom_minimum_size = Vector2(0, 96)
	panel.set_meta("card_index", index)
	if not panel.get_meta("_upgrade_signals", false):
		panel.set_meta("_upgrade_signals", true)
		panel.gui_input.connect(_on_card_gui_input_bound.bind(panel))
		panel.mouse_entered.connect(_on_card_hover_enter.bind(panel))
		panel.mouse_exited.connect(_on_card_hover_exit.bind(panel))
	var margin_n: MarginContainer = panel.get_child(0) as MarginContainer
	var row: HBoxContainer = margin_n.get_child(0) as HBoxContainer
	var icon_wrap: PanelContainer = row.get_child(0) as PanelContainer
	var text_col: VBoxContainer = row.get_child(1) as VBoxContainer
	var top_row: HBoxContainer = text_col.get_child(0) as HBoxContainer
	panel.set_meta("icon_wrap", icon_wrap)
	panel.set_meta("rarity_label", top_row.get_child(0) as Label)
	panel.set_meta("badge_label", top_row.get_child(1) as Label)
	panel.set_meta("name_label", text_col.get_child(1) as Label)
	panel.set_meta("delta_label", text_col.get_child(2) as Label)


func _on_card_gui_input_bound(ev: InputEvent, panel: Control) -> void:
	_on_card_gui_input(ev, panel)


func _apply_action_tooltips() -> void:
	if _reroll_btn:
		_reroll_btn.tooltip_text = tr("ui.upgrade_ui.tooltip_reroll_pool")
	if _skip_btn:
		_skip_btn.tooltip_text = tr("ui.upgrade_ui.tooltip_skip_gold")


func _build_ui_shell() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_root)

	var dim := ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0, 0, 0, 0.55)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.add_child(dim)

	var margin := MarginContainer.new()
	_outer_margin = margin
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	_root.add_child(margin)

	var outer := VBoxContainer.new()
	outer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	outer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	outer.add_theme_constant_override("separation", 10)
	margin.add_child(outer)

	_title = Label.new()
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.add_theme_font_size_override("font_size", 22)
	_title.add_theme_color_override("font_color", _GOLD)
	outer.add_child(_title)

	_columns = HBoxContainer.new()
	_columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_columns.add_theme_constant_override("separation", 14)
	outer.add_child(_columns)

	# --- Left: inventory ---
	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(260, 0)
	left.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	left.add_theme_constant_override("separation", 8)
	_columns.add_child(left)

	var inv_panel := PanelContainer.new()
	inv_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inv_panel.add_theme_stylebox_override("panel", _style_flat_panel(_PANEL_BG))
	left.add_child(inv_panel)

	var inv_v := VBoxContainer.new()
	inv_v.add_theme_constant_override("separation", 8)
	inv_panel.add_child(inv_v)

	inv_v.add_child(_make_section_header("ui.upgrade_ui.panel_inventory"))

	var wl := Label.new()
	wl.text = tr("ui.upgrade_ui.weapons_header")
	wl.add_theme_font_size_override("font_size", 13)
	wl.add_theme_color_override("font_color", _ACCENT)
	inv_v.add_child(wl)

	_weapons_grid = GridContainer.new()
	_weapons_grid.columns = 6
	_weapons_grid.add_theme_constant_override("h_separation", 6)
	_weapons_grid.add_theme_constant_override("v_separation", 6)
	inv_v.add_child(_weapons_grid)

	var il := Label.new()
	il.text = tr("ui.upgrade_ui.items_header")
	il.add_theme_font_size_override("font_size", 13)
	il.add_theme_color_override("font_color", _ACCENT)
	inv_v.add_child(il)

	_items_grid = GridContainer.new()
	_items_grid.columns = 6
	_items_grid.add_theme_constant_override("h_separation", 6)
	_items_grid.add_theme_constant_override("v_separation", 6)
	inv_v.add_child(_items_grid)

	# --- Center: upgrade cards ---
	var center_col := VBoxContainer.new()
	center_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center_col.add_theme_constant_override("separation", 8)
	_columns.add_child(center_col)

	center_col.add_child(_make_section_header("ui.upgrade_ui.panel_upgrades"))

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	center_col.add_child(scroll)

	_options_column = VBoxContainer.new()
	_options_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_options_column.add_theme_constant_override("separation", 10)
	scroll.add_child(_options_column)

	for i in 4:
		var card := _make_upgrade_card(i)
		_options_column.add_child(card)
		_card_nodes.append(card)

	var action := HBoxContainer.new()
	action.alignment = BoxContainer.ALIGNMENT_CENTER
	action.add_theme_constant_override("separation", 12)
	center_col.add_child(action)

	_reroll_btn = Button.new()
	_reroll_btn.custom_minimum_size = Vector2(160, 42)
	_reroll_btn.add_theme_stylebox_override("normal", _style_flat_panel(Color(0.1, 0.12, 0.2)))
	_reroll_btn.add_theme_color_override("font_color", Color.WHITE)
	action.add_child(_reroll_btn)
	_reroll_btn.pressed.connect(_on_reroll)

	_skip_btn = Button.new()
	_skip_btn.custom_minimum_size = Vector2(160, 42)
	_skip_btn.add_theme_stylebox_override("normal", _style_flat_panel(Color(0.1, 0.12, 0.2)))
	_skip_btn.add_theme_color_override("font_color", Color.WHITE)
	action.add_child(_skip_btn)
	_skip_btn.pressed.connect(_on_skip)

	# --- Right: stats ---
	var right := VBoxContainer.new()
	right.custom_minimum_size = Vector2(280, 0)
	right.size_flags_horizontal = Control.SIZE_SHRINK_END
	right.add_theme_constant_override("separation", 8)
	_columns.add_child(right)

	right.add_child(_make_section_header("ui.upgrade_ui.panel_stats"))

	var stats_panel := PanelContainer.new()
	stats_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stats_panel.add_theme_stylebox_override("panel", _style_flat_panel(_PANEL_BG))
	right.add_child(stats_panel)

	_stats_scroll = ScrollContainer.new()
	_stats_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_stats_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_stats_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	stats_panel.add_child(_stats_scroll)

	_stats_vbox = VBoxContainer.new()
	_stats_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_stats_vbox.add_theme_constant_override("separation", 4)
	_stats_scroll.add_child(_stats_vbox)


func _apply_ui_scale() -> void:
	var s: float = SaveManager.get_ui_scale()
	if _outer_margin:
		_outer_margin.add_theme_constant_override("margin_left", int(16 * s))
		_outer_margin.add_theme_constant_override("margin_right", int(16 * s))
		_outer_margin.add_theme_constant_override("margin_top", int(20 * s))
		_outer_margin.add_theme_constant_override("margin_bottom", int(20 * s))


func _make_section_header(locale_key: String) -> Control:
	var header_wrap := PanelContainer.new()
	header_wrap.add_theme_stylebox_override("panel", _style_header())
	var lab := Label.new()
	lab.text = tr(locale_key)
	lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lab.add_theme_font_size_override("font_size", 14)
	lab.add_theme_color_override("font_color", Color.WHITE)
	header_wrap.add_child(lab)
	return header_wrap


func _make_upgrade_card(index: int) -> Control:
	var panel := PanelContainer.new()
	panel.visible = false
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.custom_minimum_size = Vector2(0, 96)
	panel.add_theme_stylebox_override("panel", _style_flat_panel(Color(0.11, 0.12, 0.18), Color(0.65, 0.7, 0.75), 1))
	panel.set_meta("card_index", index)
	panel.gui_input.connect(func(ev: InputEvent): _on_card_gui_input(ev, panel))
	panel.mouse_entered.connect(func(): _on_card_hover_enter(panel))
	panel.mouse_exited.connect(func(): _on_card_hover_exit(panel))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	panel.add_child(margin)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	margin.add_child(row)

	var icon_wrap := PanelContainer.new()
	icon_wrap.custom_minimum_size = Vector2(44, 44)
	icon_wrap.add_theme_stylebox_override("panel", _style_flat_panel(_SLOT_BG, Color(0.4, 0.45, 0.5), 1))
	row.add_child(icon_wrap)
	panel.set_meta("icon_wrap", icon_wrap)

	var text_col := VBoxContainer.new()
	text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_col.add_theme_constant_override("separation", 4)
	row.add_child(text_col)

	var top_row := HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 8)
	text_col.add_child(top_row)

	var rarity := Label.new()
	rarity.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rarity.add_theme_font_size_override("font_size", 12)
	top_row.add_child(rarity)
	panel.set_meta("rarity_label", rarity)

	var badge := Label.new()
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	badge.add_theme_font_size_override("font_size", 12)
	badge.add_theme_color_override("font_color", _GOLD)
	top_row.add_child(badge)
	panel.set_meta("badge_label", badge)

	var name_l := Label.new()
	name_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_l.add_theme_font_size_override("font_size", 15)
	name_l.add_theme_color_override("font_color", Color.WHITE)
	text_col.add_child(name_l)
	panel.set_meta("name_label", name_l)

	var delta := Label.new()
	delta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	delta.add_theme_font_size_override("font_size", 12)
	delta.add_theme_color_override("font_color", _ACCENT)
	text_col.add_child(delta)
	panel.set_meta("delta_label", delta)

	return panel


func _on_card_gui_input(event: InputEvent, panel: Control) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var idx: int = int(panel.get_meta("card_index"))
		if idx >= 0 and idx < chosen_upgrades.size():
			var id: String = str(chosen_upgrades[idx].get("id", ""))
			upgrade_chosen.emit(id)


func _on_card_hover_enter(panel: Control) -> void:
	_hovered_card = panel
	_refresh_card_style(panel, true)


func _on_card_hover_exit(panel: Control) -> void:
	if _hovered_card == panel:
		_hovered_card = null
	_refresh_card_style(panel, false)


func _refresh_card_style(panel: Control, hovered: bool) -> void:
	var border := Color(0.75, 0.8, 0.85, 0.95) if hovered else Color(0.55, 0.6, 0.65, 0.85)
	var inner := Color(0.14, 0.16, 0.22) if hovered else Color(0.11, 0.12, 0.18)
	panel.add_theme_stylebox_override("panel", _style_flat_panel(inner, border, 2 if hovered else 1))


func _inventory_slot(tooltip: String, glyph: String, filled: bool, _locked: bool, icon_tex: Texture2D = null) -> Control:
	var slot := PanelContainer.new()
	slot.custom_minimum_size = Vector2(48, 48)
	slot.tooltip_text = tooltip
	var bg := _SLOT_BG if filled else _SLOT_LOCKED
	slot.add_theme_stylebox_override("panel", _style_flat_panel(bg, Color(0.35, 0.38, 0.42, 0.9), 1))
	var fs := 20 if filled else 18
	var col := Color.WHITE if filled else Color(0.35, 0.35, 0.4)
	if icon_tex != null:
		var tr_icon := TextureRect.new()
		tr_icon.texture = icon_tex
		tr_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tr_icon.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tr_icon.size_flags_vertical = Control.SIZE_EXPAND_FILL
		slot.add_child(tr_icon)
	else:
		var l := Label.new()
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		l.text = glyph
		l.add_theme_font_size_override("font_size", fs)
		l.add_theme_color_override("font_color", col)
		slot.add_child(l)
	return slot


func _rebuild_inventory_slots() -> void:
	for c in _weapons_grid.get_children():
		c.queue_free()
	for c in _items_grid.get_children():
		c.queue_free()
	if player_ref == null:
		return
	_weapons_grid.columns = maxi(1, int(player_ref.max_weapons))
	_items_grid.columns = maxi(1, int(player_ref.max_items))

	var w_ids: Array = player_ref.active_weapons.keys()
	w_ids.sort()
	for i in player_ref.max_weapons:
		if i < w_ids.size():
			var wid: String = str(w_ids[i])
			var g: String = str(_WEAPON_GLYPH.get(wid, "⚔"))
			var tip: String = player_ref.get_weapon_description(wid)
			_weapons_grid.add_child(_inventory_slot(tip, g, true, false, UpgradeIconCatalog.try_weapon(wid)))
		else:
			var empty_tip := tr("ui.upgrade_ui.slot_weapon_empty")
			_weapons_grid.add_child(_inventory_slot(empty_tip, "🔒", false, true))

	var i_ids: Array = player_ref.active_items.keys()
	i_ids.sort()
	for i in player_ref.max_items:
		if i < i_ids.size():
			var iid: String = str(i_ids[i])
			var ig: String = str(_ITEM_GLYPH.get(iid, "◇"))
			var itip: String = player_ref.get_item_description(iid)
			_items_grid.add_child(_inventory_slot(itip, ig, true, false, UpgradeIconCatalog.try_item(iid)))
		else:
			var e_tip := tr("ui.upgrade_ui.slot_item_empty")
			_items_grid.add_child(_inventory_slot(e_tip, "🔒", false, true))


func _rebuild_stats_panel() -> void:
	for c in _stats_vbox.get_children():
		c.queue_free()
	if player_ref == null:
		return

	var rows: Array = _collect_stat_rows()
	for row in rows:
		var hb := HBoxContainer.new()
		hb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var name_l := Label.new()
		name_l.text = str(row[0])
		name_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_l.add_theme_font_size_override("font_size", 12)
		name_l.add_theme_color_override("font_color", Color(0.78, 0.8, 0.82))
		hb.add_child(name_l)
		var val_l := Label.new()
		val_l.text = str(row[1])
		val_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		val_l.add_theme_font_size_override("font_size", 12)
		val_l.add_theme_color_override("font_color", Color.WHITE)
		hb.add_child(val_l)
		_stats_vbox.add_child(hb)

	var sep := HSeparator.new()
	_stats_vbox.add_child(sep)

	var meta_title := Label.new()
	meta_title.text = tr("ui.upgrade_ui.meta_header")
	meta_title.add_theme_font_size_override("font_size", 12)
	meta_title.add_theme_color_override("font_color", _ACCENT)
	_stats_vbox.add_child(meta_title)

	for mr in _collect_meta_rows():
		var h2 := HBoxContainer.new()
		h2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var k := Label.new()
		k.text = str(mr[0])
		k.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		k.add_theme_font_size_override("font_size", 11)
		k.add_theme_color_override("font_color", Color(0.7, 0.72, 0.75))
		h2.add_child(k)
		var v := Label.new()
		v.text = str(mr[1])
		v.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		v.add_theme_font_size_override("font_size", 11)
		v.add_theme_color_override("font_color", Color(0.95, 0.95, 0.98))
		h2.add_child(v)
		_stats_vbox.add_child(h2)


func _collect_stat_rows() -> Array:
	var p: Node = player_ref
	var tag_crit: float = p.get_tag_crit_bonus()
	var lifesteal_pct: float = 0.0
	if p.active_items.has("lifesteal"):
		lifesteal_pct = p.active_items["lifesteal"].steal_percent
	var crit_item: float = 0.0
	if p.active_items.has("crit"):
		crit_item = p.active_items["crit"].crit_chance
	var armor_val: float = float(SaveManager.meta_upgrades.get("armor_bonus", 0) * 2)
	if p.active_items.has("armor"):
		armor_val += float(p.active_items["armor"].armor_value)
	if p.active_items.has("glyph_charm"):
		armor_val += float(p.active_items["glyph_charm"].ward_value)
	if p.active_items.has("rampart_plate"):
		armor_val += float(p.active_items["rampart_plate"].armor_value)
	if p.active_items.has("iron_bulwark"):
		armor_val += float(p.active_items["iron_bulwark"].armor_value)

	var crit_pct: int = int(round((p.category_crit_bonus + crit_item + tag_crit) * 100.0))
	var meta_crit: float = float(SaveManager.meta_upgrades.get("crit_damage_bonus", 0)) * 0.25
	var crit_mult: float = 2.0 + meta_crit
	if p.active_items.has("crit"):
		crit_mult = float(p.active_items["crit"].crit_multiplier) + meta_crit

	var out: Array = [
		[tr("ui.upgrade_ui.statlist_max_hp"), str(p.max_hp)],
		[tr("ui.upgrade_ui.statlist_current_hp"), str(p.hp)],
		[tr("ui.player.stat_damage"), str(p.bullet_damage + p.category_damage_bonus + p.momentum_bonus)],
		[tr("ui.player.stat_armor"), str(snappedf(armor_val, 0.1))],
		[tr("ui.player.stat_lifesteal"), str(int(round(lifesteal_pct * 100.0))) + "%"],
		[tr("ui.upgrade_ui.statlist_crit_chance"), str(crit_pct) + "%"],
		[tr("ui.upgrade_ui.statlist_crit_damage"), "%.1fx" % crit_mult],
		[tr("ui.player.stat_cooldown"), str(int(round((1.0 - p.get_cooldown_multiplier()) * 100.0))) + "%"],
		[tr("ui.player.stat_area"), str(int(round((p.get_area_multiplier() - 1.0) * 100.0))) + "%"],
		[tr("ui.upgrade_ui.statlist_duration"), "%.2fx" % p.get_duration_multiplier()],
		[tr("ui.upgrade_ui.statlist_multi_shot"), str(p.get_multi_attack_bonus())],
		[tr("ui.player.stat_speed"), str(int(p.get_effective_move_speed()))],
		[tr("ui.player.stat_magnet"), str(int(p.get_magnet_bonus()))],
		[tr("ui.upgrade_ui.statlist_luck"), str(int(round(p.get_luck() * 100.0))) + "%"],
	]
	if p.overheal_shield > 0:
		out.append([tr("ui.player.stat_overheal"), str(p.overheal_shield)])
	if p.bounce_timer > 0:
		out.append([tr("ui.player.stat_bounce"), "%.1fs" % p.bounce_timer])
	if p.shrine_active:
		out.append([tr("ui.player.stat_shrine"), "%.0fs" % p.shrine_timer])
	return out


func _collect_meta_rows() -> Array:
	var m: Dictionary = SaveManager.meta_upgrades
	var rr: int = 2 + int(m.get("reroll_bonus", 0))
	var sk: int = 2 + int(m.get("skip_bonus", 0))
	if player_ref != null and is_instance_valid(player_ref):
		rr = int(player_ref.run_levelup_rerolls_left)
		sk = int(player_ref.run_levelup_skips_left)
	var ws: int = 6 + clampi(int(m.get("weapon_slot_bonus", 0)), 0, 2)
	var isl: int = 6 + clampi(int(m.get("item_slot_bonus", 0)), 0, 2)
	return [
		[tr("ui.upgrade_ui.meta_xp"), "x%.2f" % (1.0 + int(m.get("xp_bonus", 0)) * 0.1)],
		[tr("ui.upgrade_ui.meta_gold"), "x%.2f" % (1.0 + int(m.get("gold_bonus", 0)) * 0.05)],
		[tr("ui.upgrade_ui.meta_magnet_meta"), str(int(int(m.get("magnet_bonus", 0)) * 15))],
		[tr("ui.upgrade_ui.meta_cooldown_rank"), str(m.get("cooldown_bonus", 0))],
		[tr("ui.upgrade_ui.meta_area_rank"), str(m.get("area_bonus", 0))],
		[tr("ui.upgrade_ui.meta_duration_rank"), str(m.get("duration_bonus", 0))],
		[tr("ui.upgrade_ui.meta_multi_rank"), str(m.get("multi_attack_bonus", 0))],
		[tr("ui.upgrade_ui.meta_weapon_slots"), str(ws)],
		[tr("ui.upgrade_ui.meta_item_slots"), str(isl)],
		[tr("ui.upgrade_ui.meta_rerolls"), str(rr)],
		[tr("ui.upgrade_ui.meta_skips"), str(sk)],
	]


func _stat_upgrade_text(id: String) -> String:
	var key_map := {"speed": "stat_speed", "max_hp": "stat_max_hp", "heal": "stat_heal"}
	var k: String = key_map.get(id, id)
	return tr("ui.upgrade_ui." + k)


func _rarity_for_upgrade(upgrade: Dictionary) -> Dictionary:
	var id: String = str(upgrade.get("id", ""))
	if upgrade.get("is_evolution", false) or WeaponEvolution.EVOLUTIONS.has(id):
		return {"key": "rarity_evolution", "color": _RARITY_EVO}
	if id in STAT_UPGRADES:
		return {"key": "rarity_stat", "color": _RARITY_UNCOMMON}
	if player_ref.active_weapons.has(id) or player_ref.active_items.has(id):
		var lv := 1
		if player_ref.active_weapons.has(id):
			lv = int(player_ref.active_weapons[id].level)
		elif player_ref.active_items.has(id):
			lv = int(player_ref.active_items[id].level)
		if lv >= 3:
			return {"key": "rarity_rare", "color": _RARITY_RARE}
		return {"key": "rarity_uncommon", "color": _RARITY_UNCOMMON}
	return {"key": "rarity_new", "color": _RARITY_COMMON}


func _glyph_for_upgrade(id: String, is_evo: bool) -> String:
	if is_evo or WeaponEvolution.EVOLUTIONS.has(id):
		return "⚡"
	if id in WEAPON_UPGRADE_IDS:
		return str(_WEAPON_GLYPH.get(id, "⚔"))
	if id in ITEM_UPGRADE_IDS:
		return str(_ITEM_GLYPH.get(id, "◇"))
	if id == "speed":
		return "👟"
	if id == "max_hp":
		return "❤"
	if id == "heal":
		return "💚"
	return "✨"


func _upgrade_display_name(id: String, is_evo: bool) -> String:
	if is_evo or WeaponEvolution.EVOLUTIONS.has(id):
		return WeaponEvolution.localized_name(id)
	if id in WEAPON_UPGRADE_IDS:
		var nk := "codex.weapon.%s.name" % id
		var nm: String = tr(nk)
		if nm == nk or nm.is_empty():
			return id.capitalize()
		return nm
	if id in ITEM_UPGRADE_IDS:
		var ik := "codex.item.%s.name" % id
		var im: String = tr(ik)
		if im == ik or im.is_empty():
			return id.capitalize()
		return im
	return _stat_upgrade_text(id).split("\n")[0]


func _preview_effect_text(upgrade: Dictionary) -> String:
	var id: String = str(upgrade.get("id", ""))
	var is_evo: bool = upgrade.get("is_evolution", false) or WeaponEvolution.EVOLUTIONS.has(id)

	if is_evo:
		return tr("ui.upgrade_ui.evo_body") + "\n" + WeaponEvolution.localized_description(id)

	if id == "speed":
		var cur: float = float(player_ref.SPEED)
		var nxt: float = minf(cur + 10.0, float(player_ref.MAX_MOVE_SPEED))
		return tr("ui.upgrade_ui.delta_move_speed") % [int(cur), int(nxt)]
	if id == "max_hp":
		return tr("ui.upgrade_ui.delta_max_hp") % [player_ref.max_hp, player_ref.max_hp + 15]
	if id == "heal":
		var nh: int = mini(player_ref.hp + 12, player_ref.max_hp)
		return tr("ui.upgrade_ui.delta_heal") % [player_ref.hp, nh]

	if id in WEAPON_UPGRADE_IDS:
		var pair: PackedStringArray = _preview_weapon_descriptions(id)
		if pair.size() >= 2:
			return tr("ui.upgrade_ui.delta_line_before") + " " + pair[0] + "\n" + tr("ui.upgrade_ui.delta_line_after") + " " + pair[1]
		if pair.size() == 1:
			return pair[0]
		return tr("ui.upgrade_ui.preview_unavailable")

	if id in ITEM_UPGRADE_IDS:
		var ip: PackedStringArray = _preview_item_descriptions(id)
		if ip.size() >= 2:
			return tr("ui.upgrade_ui.delta_line_before") + " " + ip[0] + "\n" + tr("ui.upgrade_ui.delta_line_after") + " " + ip[1]
		if ip.size() == 1:
			return ip[0]
		return tr("ui.upgrade_ui.preview_unavailable")

	return tr("ui.upgrade_ui.preview_unavailable")


## Eski `weapon_aura`: halka `player` altına ekleniyordu; taşıma sonrası kalan serseri Sprite2D temizliği.
func _remove_stray_aura_rings_on_player() -> void:
	if player_ref == null or not is_instance_valid(player_ref):
		return
	for c in player_ref.get_children():
		if c is Sprite2D and str(c.name) == "AuraWeaponRing":
			c.queue_free()


func _codex_weapon_preview_only(weapon_id: String) -> PackedStringArray:
	var nk: String = "codex.weapon.%s.name" % weapon_id
	var nm: String = tr(nk)
	if nm == nk or nm.is_empty():
		nm = weapon_id.capitalize()
	var dk: String = "codex.weapon.%s.desc" % weapon_id
	var ds: String = tr(dk)
	if ds != dk and not ds.is_empty():
		return PackedStringArray([nm + "\n" + ds])
	return PackedStringArray([nm])


func _codex_item_preview_only(item_id: String) -> PackedStringArray:
	var nk: String = "codex.item.%s.name" % item_id
	var nm: String = tr(nk)
	if nm == nk or nm.is_empty():
		nm = item_id.capitalize()
	var dk: String = "codex.item.%s.desc" % item_id
	var ds: String = tr(dk)
	if ds != dk and not ds.is_empty():
		return PackedStringArray([nm + "\n" + ds])
	return PackedStringArray([nm])


func _preview_weapon_descriptions(weapon_id: String) -> PackedStringArray:
	if player_ref.active_weapons.has(weapon_id):
		var src: Node = player_ref.active_weapons[weapon_id]
		if int(src.level) >= int(src.max_level):
			return PackedStringArray([src.get_description()])
		var dup_flags: int = Node.DUPLICATE_USE_INSTANTIATION | Node.DUPLICATE_SCRIPTS | Node.DUPLICATE_GROUPS
		var dup: Node = src.duplicate(dup_flags)
		dup.player = player_ref
		var before: String = str(src.get_description())
		if int(dup.level) < int(dup.max_level):
			dup.upgrade()
		var after: String = str(dup.get_description())
		dup.queue_free()
		return PackedStringArray([before, after])

	# Yeni silah: oyuncuya geçici düğüm ekleme (Aura vb. `call_deferred` yan etkileri / çökme riski).
	return _codex_weapon_preview_only(weapon_id)


func _preview_item_descriptions(item_id: String) -> PackedStringArray:
	if player_ref.active_items.has(item_id):
		var src: Node = player_ref.active_items[item_id]
		if int(src.level) >= int(src.max_level):
			return PackedStringArray([src.get_description()])
		var idup_flags: int = Node.DUPLICATE_USE_INSTANTIATION | Node.DUPLICATE_SCRIPTS | Node.DUPLICATE_GROUPS
		var dup: Node = src.duplicate(idup_flags)
		dup.player = player_ref
		var before: String = str(src.get_description())
		dup.level = int(src.level) + 1
		if dup.has_method("apply"):
			dup.apply()
		var after: String = str(dup.get_description())
		dup.queue_free()
		return PackedStringArray([before, after])

	# Yeni eşya: `PassiveItem` = `Node` → `visible` yok; geçici child yerine kodeks özeti.
	return _codex_item_preview_only(item_id)


func _badge_text(upgrade: Dictionary) -> String:
	var id: String = str(upgrade.get("id", ""))
	var is_evo: bool = upgrade.get("is_evolution", false) or WeaponEvolution.EVOLUTIONS.has(id)
	if is_evo:
		return tr("ui.upgrade_ui.badge_evo")
	if id in STAT_UPGRADES:
		return tr("ui.upgrade_ui.badge_pick")
	if player_ref.active_weapons.has(id):
		var wn = player_ref.active_weapons[id]
		return tr("ui.upgrade_ui.badge_level") % int(wn.level + 1) if int(wn.level) < int(wn.max_level) else tr("ui.upgrade_ui.badge_max")
	if player_ref.active_items.has(id):
		var it = player_ref.active_items[id]
		return tr("ui.upgrade_ui.badge_level") % int(it.level + 1) if int(it.level) < int(it.max_level) else tr("ui.upgrade_ui.badge_max")
	return tr("ui.upgrade_ui.badge_new")


func build_pool() -> Array:
	var pool: Array = []
	var luck: float = player_ref.get_luck()

	var available_evos: Array = WeaponEvolution.get_available_evolutions(player_ref)
	for evo_id in available_evos:
		pool.append({
			"id": evo_id,
			"weight": WeaponEvolution.get_evolution_weight(evo_id),
			"is_evolution": true
		})

	var prog: bool = has_progression_upgrades(player_ref)
	for id in STAT_UPGRADES:
		if id == "max_hp" and not prog:
			continue
		if id == "speed" and (not prog or float(player_ref.SPEED) >= float(player_ref.MAX_MOVE_SPEED)):
			continue
		if id == "heal" and not prog:
			continue
		pool.append({"id": id, "weight": 0.32, "is_evolution": false})

	for id in WEAPON_UPGRADE_IDS:
		if player_ref.active_weapons.has(id):
			var w: Node = player_ref.active_weapons[id]
			if int(w.level) < int(w.max_level):
				pool.append({"id": id, "weight": 2.0 + luck * 0.5, "is_evolution": false})
		else:
			if player_ref.can_add_weapon():
				pool.append({"id": id, "weight": 0.3 + luck * 0.2, "is_evolution": false})
	for id in ITEM_UPGRADE_IDS:
		if player_ref.active_items.has(id):
			var i: Node = player_ref.active_items[id]
			if int(i.level) < int(i.max_level):
				pool.append({"id": id, "weight": 2.0 + luck * 0.5, "is_evolution": false})
		else:
			if player_ref.can_add_item():
				pool.append({"id": id, "weight": 0.3 + luck * 0.2, "is_evolution": false})

	return pool


func weighted_pick(pool: Array, count: int) -> Array:
	var chosen: Array = []
	var remaining: Array = pool.duplicate()

	var evolutions: Array = remaining.filter(func(x): return x.get("is_evolution", false))
	var non_evolutions: Array = remaining.filter(func(x): return not x.get("is_evolution", false))

	for evo in evolutions:
		if chosen.size() < count:
			chosen.append(evo)
			remaining.erase(evo)

	remaining = non_evolutions

	for _i in count - chosen.size():
		if remaining.is_empty():
			break
		var total_weight: float = 0.0
		for item in remaining:
			total_weight += float(item["weight"])
		var roll: float = randf() * total_weight
		var cumulative: float = 0.0
		for j in remaining.size():
			cumulative += float(remaining[j]["weight"])
			if roll <= cumulative:
				chosen.append(remaining[j])
				remaining.remove_at(j)
				break

	return chosen


func get_upgrade_text(id: String) -> String:
	if player_ref == null:
		return id
	if WeaponEvolution.EVOLUTIONS.has(id):
		var title: String = tr("ui.upgrade_ui.evolution_pick_title")
		return title + "\n" + WeaponEvolution.localized_name(id) + "\n" + WeaponEvolution.localized_description(id)
	if id in WEAPON_UPGRADE_IDS:
		return player_ref.get_weapon_description(id)
	if id in ITEM_UPGRADE_IDS:
		return player_ref.get_item_description(id)
	if id in STAT_UPGRADES:
		return _stat_upgrade_text(id)
	return id


func refresh_buttons() -> void:
	var buttons: Array = _option_buttons()
	for i in chosen_upgrades.size():
		var upgrade: Dictionary = chosen_upgrades[i]
		var id: String = str(upgrade.get("id", ""))
		var is_evo: bool = upgrade.get("is_evolution", false) or WeaponEvolution.EVOLUTIONS.has(id)
		var panel: Control = buttons[i]
		panel.set_meta("upgrade_id", id)
		panel.visible = true

		var rarity: Dictionary = _rarity_for_upgrade(upgrade)
		var rlab: Label = panel.get_meta("rarity_label")
		rlab.text = tr("ui.upgrade_ui." + str(rarity["key"]))
		rlab.add_theme_color_override("font_color", rarity["color"])

		var badge: Label = panel.get_meta("badge_label")
		badge.text = _badge_text(upgrade)

		var icon_wrap: PanelContainer = panel.get_meta("icon_wrap")
		_populate_icon_wrap(icon_wrap, _texture_for_upgrade_card(id, is_evo), _glyph_for_upgrade(id, is_evo))

		var name_l: Label = panel.get_meta("name_label")
		name_l.text = _upgrade_display_name(upgrade.get("id", ""), is_evo)

		var delta: Label = panel.get_meta("delta_label")
		delta.text = _preview_effect_text(upgrade)
		delta.add_theme_color_override("font_color", _ACCENT)
		if is_evo:
			delta.add_theme_color_override("font_color", _GOLD)

		var psty: StyleBoxFlat = _style_flat_panel(Color(0.18, 0.14, 0.08), _RARITY_EVO, 2) if is_evo else _style_flat_panel(Color(0.11, 0.12, 0.18))
		panel.add_theme_stylebox_override("panel", psty)

	for i in range(chosen_upgrades.size(), buttons.size()):
		buttons[i].visible = false

	_reroll_btn.text = tr("ui.upgrade_ui.reroll") % reroll_count
	_reroll_btn.disabled = reroll_count <= 0
	_skip_btn.text = tr("ui.upgrade_ui.skip") % skip_count
	_skip_btn.disabled = skip_count <= 0


func show_upgrades(player: Node) -> void:
	player_ref = player
	_remove_stray_aura_rings_on_player()
	reroll_count = int(player_ref.run_levelup_rerolls_left)
	skip_count = int(player_ref.run_levelup_skips_left)

	pick_count = 4 if player_ref.get("cog_shard_bonus_active") else 3
	_layout_levelup_panel(pick_count)

	current_pool = build_pool()
	chosen_upgrades = weighted_pick(current_pool, pick_count)
	if player_ref.get("cog_shard_bonus_active"):
		player_ref.cog_shard_bonus_active = false
		player_ref.cog_shard_count = 0
	if player_ref.has_method("_update_cog_label"):
		player_ref._update_cog_label()

	var char_index: int = SaveManager.get_character_index_for_player(player_ref.player_id)
	var char_name: String = CharacterData.CHARACTERS[char_index]["name"]
	var player_label: String = "P1" if player_ref.player_id == 0 else "P2"
	if SaveManager.game_mode == "local_coop":
		_title.text = tr("ui.upgrade_ui.title_coop") % [char_name, player_label, player_ref.level]
	else:
		_title.text = tr("ui.upgrade_ui.title_solo") % player_ref.level

	_apply_ui_scale()
	_rebuild_inventory_slots()
	_rebuild_stats_panel()
	refresh_buttons()
	visible = true


func _on_reroll() -> void:
	if reroll_count <= 0:
		return
	reroll_count -= 1
	player_ref.run_levelup_rerolls_left = reroll_count
	current_pool = build_pool()
	chosen_upgrades = weighted_pick(current_pool, pick_count)
	refresh_buttons()


func _on_skip() -> void:
	if skip_count <= 0:
		return
	skip_count -= 1
	player_ref.run_levelup_skips_left = skip_count
	player_ref.gold_earned += 25
	if SaveManager.game_mode != "local_coop":
		var gl: Node = player_ref.get_node_or_null("CanvasLayer/StatsRow/GoldLabel")
		if gl:
			gl.text = "💰 " + str(player_ref.gold_earned)
	upgrade_chosen.emit("skip")
	visible = false


static func has_progression_upgrades(player: Node) -> bool:
	if player == null or not is_instance_valid(player):
		return false
	if not WeaponEvolution.get_available_evolutions(player).is_empty():
		return true
	for id in WEAPON_UPGRADE_IDS:
		if player.active_weapons.has(id):
			var w: Node = player.active_weapons[id]
			if int(w.level) < int(w.max_level):
				return true
		else:
			if player.can_add_weapon():
				return true
	for id in ITEM_UPGRADE_IDS:
		if player.active_items.has(id):
			var i: Node = player.active_items[id]
			if int(i.level) < int(i.max_level):
				return true
		else:
			if player.can_add_item():
				return true
	return false
