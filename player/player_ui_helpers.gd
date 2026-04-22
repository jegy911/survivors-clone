class_name PlayerUiHelpers
extends RefCounted
## Level-up VFX ve hız sinerjisi izi; `player.gd` boyutunu küçültür.


static func spawn_levelup_effect(player: Node2D) -> void:
	var vfx_a: float = player.get_player_vfx_opacity()
	for i in 5:
		var ring := ColorRect.new()
		ring.size = Vector2(30, 30)
		ring.color = Color("#FFD700")
		ring.modulate.a = vfx_a
		ring.position = player.global_position - Vector2(15, 15)
		player.get_parent().add_child(ring)
		var tween := ring.create_tween()
		var target_size := Vector2(180 + i * 80, 180 + i * 80)
		var target_pos := player.global_position - target_size / 2
		tween.set_parallel(true)
		tween.tween_property(ring, "size", target_size, 0.35 + i * 0.08)
		tween.tween_property(ring, "position", target_pos, 0.35 + i * 0.08)
		tween.tween_property(ring, "modulate:a", 0.0, 0.35 + i * 0.08)
		tween.set_parallel(false)
		tween.tween_callback(ring.queue_free)


static func spawn_levelup_screen_flash(player: Node2D) -> void:
	var flash := ColorRect.new()
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash.color = Color.WHITE
	flash.modulate = Color(1, 1, 1, 0)
	flash.z_index = 100
	var vp_size: Vector2 = player.get_viewport().get_visible_rect().size
	flash.size = vp_size * 2
	flash.position = -vp_size / 2
	var layer := CanvasLayer.new()
	layer.layer = 100
	layer.add_child(flash)
	player.get_tree().root.add_child(layer)
	var peak_a: float = 0.7 * player.get_player_vfx_opacity()
	var tween := flash.create_tween()
	tween.tween_property(flash, "modulate", Color(1, 1, 1, peak_a), 0.06)
	tween.tween_property(flash, "modulate", Color(1, 1, 1, 0), 0.4)
	tween.tween_callback(layer.queue_free)


static func spawn_speed_synergy_trail(player: Node2D) -> void:
	var trail := ColorRect.new()
	trail.size = Vector2(10, 10)
	trail.color = Color("#00FFFF")
	trail.modulate.a = 0.6 * player.get_player_vfx_opacity()
	trail.global_position = player.global_position - Vector2(5, 5)
	player.get_parent().add_child(trail)
	var tween := trail.create_tween()
	tween.tween_property(trail, "modulate:a", 0.0, 0.4)
	tween.tween_callback(trail.queue_free)
	var enemies: Array = EnemyRegistry.get_enemies()
	var dmg: int = int(player.bullet_damage * 0.3)
	for enemy in enemies:
		if enemy.global_position.distance_to(player.global_position) < 30:
			enemy.take_damage(dmg)


## `upgrade_ui.gd` ile aynı yedek glifler (ikon PNG yoksa).
const _RUN_WEAPON_GLYPH: Dictionary = {
	"bullet": "◎", "dagger": "🗡", "aura": "◇", "chain": "⛓", "boomerang": "↺", "lightning": "⚡",
	"ice_ball": "❄", "shadow": "▓", "laser": "╾", "fan_blade": "✦", "hex_sigil": "⬡",
	"gravity_anchor": "◎", "bastion_flail": "⛓", "shield_ram": "▶", "holy_bullet": "✧",
	"toxic_chain": "☠", "death_laser": "☇", "blood_boomerang": "🩸", "storm": "🌩",
	"shadow_storm": "🌑", "frost_nova": "❅", "ember_fan": "🔥", "binding_circle": "⭕",
	"void_lens": "◉", "citadel_flail": "⚔", "fortress_ram": "🛡", "veil_daggers": "🗡",
	"arc_pulse": "◎", "arc_surge": "✶",
}

const _RUN_ITEM_GLYPH: Dictionary = {
	"lifesteal": "♥", "armor": "🛡", "crit": "✴", "explosion": "💥", "magnet": "🧲", "poison": "☠",
	"shield": "◇", "speed_charm": "👟", "blood_pool": "🩸", "luck_stone": "🍀", "turbine": "⚙",
	"steam_armor": "♨", "energy_cell": "🔋", "ember_heart": "🔥", "glyph_charm": "✧",
	"resonance_stone": "◇", "rampart_plate": "🧱", "iron_bulwark": "⛨", "night_vial": "🌙",
	"field_lens": "🔍",
}

const _MEGA_PANEL_BG := Color(0.08, 0.22, 0.20, 0.91)
const _MEGA_PANEL_BORDER := Color(0.22, 0.52, 0.46, 0.78)
const _SLOT_FILL_BG := Color(0.06, 0.14, 0.12, 0.98)
const _SLOT_EMPTY_BG := Color(0.04, 0.06, 0.06, 0.72)


static func _run_hud_stylebox(bg: Color, border: Color, s: float) -> StyleBoxFlat:
	var st := StyleBoxFlat.new()
	st.bg_color = bg
	st.border_color = border
	st.set_border_width_all(maxi(1, int(s)))
	st.corner_radius_top_left = int(6 * s)
	st.corner_radius_top_right = int(6 * s)
	st.corner_radius_bottom_left = int(6 * s)
	st.corner_radius_bottom_right = int(6 * s)
	return st


static func _run_weapon_glyph(id: String) -> String:
	return str(_RUN_WEAPON_GLYPH.get(id, "⚔"))


static func _run_item_glyph(id: String) -> String:
	return str(_RUN_ITEM_GLYPH.get(id, "◇"))


static func _make_run_loadout_slot(
	tex: Texture2D,
	glyph: String,
	tip: String,
	level: int,
	filled: bool,
	s: float
) -> Control:
	var col := VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", int(3 * s))
	col.tooltip_text = tip
	var slot := PanelContainer.new()
	var bg: Color = _SLOT_FILL_BG if filled else _SLOT_EMPTY_BG
	var bd := Color(0.18, 0.42, 0.38, 0.55) if filled else Color(0.12, 0.18, 0.18, 0.4)
	slot.custom_minimum_size = Vector2(int(44 * s), int(40 * s))
	slot.add_theme_stylebox_override("panel", _run_hud_stylebox(bg, bd, s))
	if tex != null:
		var tr_icon := TextureRect.new()
		tr_icon.texture = tex
		tr_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tr_icon.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tr_icon.size_flags_vertical = Control.SIZE_EXPAND_FILL
		slot.add_child(tr_icon)
	else:
		var lab := Label.new()
		lab.text = glyph
		lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lab.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lab.size_flags_vertical = Control.SIZE_EXPAND_FILL
		lab.add_theme_font_size_override("font_size", int(20 * s))
		lab.add_theme_color_override("font_color", Color(0.92, 0.95, 0.98, 0.95) if filled else Color(0.35, 0.38, 0.4, 0.9))
		slot.add_child(lab)
	col.add_child(slot)
	var lv := Label.new()
	var fmt: String = LocalizationManager.tr_en_source("ui.player.loadout_slot_lvl")
	lv.text = fmt % level
	lv.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lv.add_theme_font_size_override("font_size", int(11 * s))
	lv.add_theme_color_override("font_color", Color(0.96, 0.98, 1.0))
	lv.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.88))
	lv.add_theme_constant_override("outline_size", maxi(2, int(3 * s)))
	col.add_child(lv)
	return col


static func _make_run_loadout_empty_slot(s: float, empty_tip: String) -> Control:
	var col := VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", int(3 * s))
	col.tooltip_text = empty_tip
	var slot := PanelContainer.new()
	slot.custom_minimum_size = Vector2(int(44 * s), int(40 * s))
	slot.add_theme_stylebox_override("panel", _run_hud_stylebox(_SLOT_EMPTY_BG, Color(0.1, 0.14, 0.14, 0.35), s))
	var dot := Label.new()
	dot.text = "·"
	dot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dot.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	dot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dot.size_flags_vertical = Control.SIZE_EXPAND_FILL
	dot.add_theme_font_size_override("font_size", int(22 * s))
	dot.add_theme_color_override("font_color", Color(0.25, 0.3, 0.3, 0.65))
	slot.add_child(dot)
	col.add_child(slot)
	var lv := Label.new()
	lv.text = " "
	lv.add_theme_font_size_override("font_size", int(11 * s))
	col.add_child(lv)
	return col


## Koşu HUD: silah / eşya satırları (ikon + LVL). `upgrade_ui` envanterine paralel.
static func rebuild_run_loadout_hud(player: Node) -> void:
	var cat: Control = player.get_node_or_null("CanvasLayer/CategoryPanel") as Control
	if cat == null:
		return
	for c in cat.get_children():
		c.queue_free()
	var s: float = SaveManager.get_ui_scale()
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", int(6 * s))
	root.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	cat.add_child(root)
	var outer := PanelContainer.new()
	outer.add_theme_stylebox_override("panel", _run_hud_stylebox(_MEGA_PANEL_BG, _MEGA_PANEL_BORDER, s))
	root.add_child(outer)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", int(8 * s))
	margin.add_theme_constant_override("margin_right", int(8 * s))
	margin.add_theme_constant_override("margin_top", int(6 * s))
	margin.add_theme_constant_override("margin_bottom", int(8 * s))
	outer.add_child(margin)
	var inner := VBoxContainer.new()
	inner.add_theme_constant_override("separation", int(7 * s))
	margin.add_child(inner)
	var wrow := HBoxContainer.new()
	wrow.add_theme_constant_override("separation", int(5 * s))
	inner.add_child(wrow)
	var irow := HBoxContainer.new()
	irow.add_theme_constant_override("separation", int(5 * s))
	inner.add_child(irow)

	var max_w: int = int(player.max_weapons)
	var max_i: int = int(player.max_items)
	var w_ids: Array = player.active_weapons.keys()
	w_ids.sort()
	for idx in max_w:
		if idx < w_ids.size():
			var wid: String = str(w_ids[idx])
			var wnode: Node = player.active_weapons[wid]
			var lvl: int = int(wnode.get("level")) if wnode.get("level") != null else 1
			var tex: Texture2D = UpgradeIconCatalog.try_weapon_with_evolution_fallback(wid)
			var tip: String = player.get_weapon_description(wid)
			wrow.add_child(_make_run_loadout_slot(tex, _run_weapon_glyph(wid), tip, lvl, true, s))
		else:
			wrow.add_child(_make_run_loadout_empty_slot(s, player.tr("ui.upgrade_ui.slot_weapon_empty")))

	var i_ids: Array = player.active_items.keys()
	i_ids.sort()
	for idx in max_i:
		if idx < i_ids.size():
			var iid: String = str(i_ids[idx])
			var inode: Node = player.active_items[iid]
			var ilvl: int = int(inode.get("level")) if inode.get("level") != null else 1
			var itex: Texture2D = UpgradeIconCatalog.try_item(iid)
			var itip: String = player.get_item_description(iid)
			irow.add_child(_make_run_loadout_slot(itex, _run_item_glyph(iid), itip, ilvl, true, s))
		else:
			irow.add_child(_make_run_loadout_empty_slot(s, player.tr("ui.upgrade_ui.slot_item_empty")))

	var slot_w: int = int(48 * s)
	var pad: int = int(22 * s)
	var cols: int = maxi(max_w, max_i)
	var need_w: int = pad * 2 + cols * slot_w
	var need_h: int = int(128 * s)
	cat.offset_right = cat.offset_left + float(need_w)
	cat.offset_bottom = cat.offset_top + float(need_h)
