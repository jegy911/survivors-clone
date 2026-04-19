extends RefCounted
class_name CharacterSelectStatsPanel

const BONUS_GREEN := Color(0.18, 0.80, 0.45)


static func _run_base() -> Dictionary:
	var m: Dictionary = SaveManager.meta_upgrades
	return {
		"max_hp": 100 + int(m.get("max_hp_bonus", 0)) * 25,
		"damage": 10 + int(m.get("damage_bonus", 0)) * 5,
		"speed": mini(300, 130 + int(m.get("speed_bonus", 0)) * 10),
		"armor": int(m.get("armor_bonus", 0)) * 2,
	}


static func _add_row(parent: VBoxContainer, name_text: String, value_text: String) -> void:
	var hb := HBoxContainer.new()
	hb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var nl := Label.new()
	nl.text = name_text
	nl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nl.add_theme_font_size_override("font_size", 13)
	nl.add_theme_color_override("font_color", Color(0.78, 0.8, 0.82))
	hb.add_child(nl)
	var vl := Label.new()
	vl.text = value_text
	vl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	vl.add_theme_font_size_override("font_size", 13)
	vl.add_theme_color_override("font_color", Color.WHITE)
	hb.add_child(vl)
	parent.add_child(hb)


static func _add_green_line(parent: VBoxContainer, text: String) -> void:
	var l := Label.new()
	l.text = text
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_size_override("font_size", 12)
	l.add_theme_color_override("font_color", BONUS_GREEN)
	parent.add_child(l)


static func _append_flat_bonuses(parent: VBoxContainer, cd: Dictionary) -> void:
	var dmg: int = int(cd.get("bonus_damage", 0))
	var hp: int = int(cd.get("bonus_hp", 0))
	var spd: int = int(cd.get("bonus_speed", 0))
	var arm: int = int(cd.get("bonus_armor", 0))
	if dmg > 0:
		_add_green_line(parent, "+%d %s" % [dmg, TranslationServer.translate("ui.player.stat_damage")])
	if hp > 0:
		_add_green_line(parent, "+%d %s" % [hp, TranslationServer.translate("ui.upgrade_ui.statlist_max_hp")])
	if spd > 0:
		_add_green_line(parent, "+%d %s" % [spd, TranslationServer.translate("ui.player.stat_speed")])
	if arm > 0:
		_add_green_line(parent, "+%d %s" % [arm, TranslationServer.translate("ui.player.stat_armor")])


static func _append_origin_bonus_lines(parent: VBoxContainer, cd: Dictionary) -> void:
	var ob: Variant = cd.get("origin_bonus", {})
	if not (ob is Dictionary):
		return
	var origin: Dictionary = ob as Dictionary
	var t: String = str(origin.get("type", ""))
	match t:
		"damage_flat":
			var a: int = int(origin.get("amount", 0))
			if a != 0:
				_add_green_line(parent, "+%d %s (%s)" % [a, TranslationServer.translate("ui.player.stat_damage"), TranslationServer.translate("ui.character_select.stats_origin_tag")])
		"armor_flat":
			var a2: int = int(origin.get("amount", 0))
			if a2 != 0:
				_add_green_line(parent, "+%d %s (%s)" % [a2, TranslationServer.translate("ui.player.stat_armor"), TranslationServer.translate("ui.character_select.stats_origin_tag")])
		"area_pct":
			var p: int = int(round(absf(float(origin.get("amount", 0.0))) * 100.0))
			_add_green_line(parent, "+%d%% %s (%s)" % [p, TranslationServer.translate("ui.player.stat_area"), TranslationServer.translate("ui.character_select.stats_origin_tag")])
		"speed_pct":
			var ps: int = int(round(absf(float(origin.get("amount", 0.0))) * 100.0))
			_add_green_line(parent, "+%d%% %s (%s)" % [ps, TranslationServer.translate("ui.player.stat_speed"), TranslationServer.translate("ui.character_select.stats_origin_tag")])
		"cooldown_pct":
			var pc: int = int(round(absf(float(origin.get("amount", 0.0))) * 100.0))
			_add_green_line(parent, "-%d%% %s (%s)" % [pc, TranslationServer.translate("ui.player.stat_cooldown"), TranslationServer.translate("ui.character_select.stats_origin_tag")])
		"hp_pct":
			var ph: int = int(round(absf(float(origin.get("amount", 0.0))) * 100.0))
			_add_green_line(parent, "+%d%% %s (%s)" % [ph, TranslationServer.translate("ui.upgrade_ui.statlist_max_hp"), TranslationServer.translate("ui.character_select.stats_origin_tag")])
		"xp_pct":
			var px: int = int(round(absf(float(origin.get("amount", 0.0))) * 100.0))
			_add_green_line(parent, "+%d%% XP (%s)" % [px, TranslationServer.translate("ui.character_select.stats_origin_tag")])
		"lifesteal_pct":
			var pl: int = int(round(absf(float(origin.get("amount", 0.0))) * 100.0))
			_add_green_line(parent, "+%d%% %s (%s)" % [pl, TranslationServer.translate("ui.player.stat_lifesteal"), TranslationServer.translate("ui.character_select.stats_origin_tag")])
		"projectile_count":
			var n: int = int(origin.get("amount", 0))
			if n != 0:
				_add_green_line(parent, "+%d %s (%s)" % [n, TranslationServer.translate("ui.upgrade_ui.statlist_multi_shot"), TranslationServer.translate("ui.character_select.stats_origin_tag")])
		"single_weapon":
			_add_green_line(parent, TranslationServer.translate("ui.character_select.stats_origin_single_weapon"))
		"slow_double":
			_add_green_line(parent, TranslationServer.translate("ui.character_select.stats_origin_slow_double"))
		_:
			pass

	var sp: String = str(cd.get("special", ""))
	if not sp.is_empty():
		var orig_t: String = str(origin.get("type", ""))
		if sp == "slow_double" and orig_t == "slow_double":
			pass
		else:
			var sk: String = "ui.character_select.special.%s" % sp
			if TranslationServer.translate(sk) != sk:
				_add_green_line(parent, TranslationServer.translate(sk))


static func rebuild(stats_vbox: VBoxContainer, selected_index: int) -> void:
	for c in stats_vbox.get_children():
		c.queue_free()

	var title := Label.new()
	title.text = TranslationServer.translate("ui.upgrade_ui.panel_stats")
	title.add_theme_font_size_override("font_size", 15)
	title.add_theme_color_override("font_color", Color("#9B59B6"))
	stats_vbox.add_child(title)

	var sub := Label.new()
	sub.text = TranslationServer.translate("ui.character_select.stats_run_base")
	sub.add_theme_font_size_override("font_size", 11)
	sub.add_theme_color_override("font_color", Color(0.65, 0.67, 0.7))
	stats_vbox.add_child(sub)

	var b: Dictionary = _run_base()
	_add_row(stats_vbox, TranslationServer.translate("ui.upgrade_ui.statlist_max_hp"), str(b["max_hp"]))
	_add_row(stats_vbox, TranslationServer.translate("ui.player.stat_damage"), str(b["damage"]))
	_add_row(stats_vbox, TranslationServer.translate("ui.player.stat_speed"), str(b["speed"]))
	_add_row(stats_vbox, TranslationServer.translate("ui.player.stat_armor"), str(b["armor"]))

	stats_vbox.add_child(HSeparator.new())

	if selected_index < 0 or selected_index >= CharacterData.CHARACTERS.size():
		var hint := Label.new()
		hint.text = TranslationServer.translate("ui.character_select.stats_select_hint")
		hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		hint.add_theme_font_size_override("font_size", 11)
		hint.add_theme_color_override("font_color", Color(0.55, 0.58, 0.62))
		stats_vbox.add_child(hint)
		return

	var cd: Dictionary = CharacterData.CHARACTERS[selected_index]
	var h2 := Label.new()
	h2.text = TranslationServer.translate("ui.character_select.stats_hero_bonus")
	h2.add_theme_font_size_override("font_size", 11)
	h2.add_theme_color_override("font_color", Color(0.65, 0.67, 0.7))
	stats_vbox.add_child(h2)

	var hero_name := Label.new()
	hero_name.text = CharacterSelectHelpers.character_display_name(str(cd["id"]))
	hero_name.add_theme_font_size_override("font_size", 12)
	hero_name.add_theme_color_override("font_color", Color.WHITE)
	stats_vbox.add_child(hero_name)

	_append_flat_bonuses(stats_vbox, cd)
	_append_origin_bonus_lines(stats_vbox, cd)
