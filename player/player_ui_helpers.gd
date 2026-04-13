class_name PlayerUiHelpers
extends RefCounted
## Level-up VFX, hız sinerjisi izi ve istatistik paneli; `player.gd` boyutunu küçültür.


static func _t(key: String) -> String:
	return TranslationServer.translate(StringName(key))


static func _stat_tag_row(tr_key: String, count: int) -> Array:
	var fmt: String = _t(tr_key)
	if fmt.contains("%d") or fmt.contains("%s"):
		return [fmt % count, ""]
	return [fmt + " x" + str(count), ""]


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


static func toggle_stats_panel(player: Node) -> void:
	if player._stat_panel and is_instance_valid(player._stat_panel):
		player._stat_panel.queue_free()
		player._stat_panel = null
		return

	var layer := CanvasLayer.new()
	layer.layer = 50
	player.get_tree().root.add_child(layer)
	player._stat_panel = layer

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(220, 0)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#0D0D1AEE")
	style.border_color = Color("#9B59B6")
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	panel.add_theme_stylebox_override("panel", style)
	panel.position = Vector2(10, 50)
	layer.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = _t("ui.player.hud_stats_title")
	title.add_theme_color_override("font_color", Color("#9B59B6"))
	title.add_theme_font_size_override("font_size", 16)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var tag_counts: Dictionary = player.get_weapon_tag_counts()
	var tag_crit: float = player.get_tag_crit_bonus()
	var lifesteal_pct: float = 0.0
	if player.active_items.has("lifesteal"):
		lifesteal_pct = player.active_items["lifesteal"].steal_percent
	var crit_item: float = 0.0
	if player.active_items.has("crit"):
		crit_item = player.active_items["crit"].crit_chance
	var armor_val: float = float(SaveManager.meta_upgrades.get("armor_bonus", 0) * 2)
	if player.active_items.has("armor"):
		armor_val += float(player.active_items["armor"].armor_value)
	if player.active_items.has("glyph_charm"):
		armor_val += float(player.active_items["glyph_charm"].ward_value)
	if player.active_items.has("rampart_plate"):
		armor_val += float(player.active_items["rampart_plate"].armor_value)
	if player.active_items.has("iron_bulwark"):
		armor_val += float(player.active_items["iron_bulwark"].armor_value)

	var stats_list: Array = [
		[_t("ui.player.stat_damage"), str(player.bullet_damage + player.category_damage_bonus + player.momentum_bonus)],
		[_t("ui.player.stat_hp"), str(player.hp) + "/" + str(player.max_hp)],
		[_t("ui.player.stat_armor"), str(snappedf(armor_val, 0.1))],
		[_t("ui.player.stat_lifesteal"), str(int(round(lifesteal_pct * 100.0))) + "%"],
		[_t("ui.player.stat_crit"), str(int(round((player.category_crit_bonus + crit_item + tag_crit) * 100.0))) + "%"],
		[_t("ui.player.stat_cooldown"), str(int(round((1.0 - player.get_cooldown_multiplier()) * 100.0))) + "%"],
		[_t("ui.player.stat_area"), str(int(round((player.get_area_multiplier() - 1.0) * 100.0))) + "%"],
		[_t("ui.player.stat_speed"), str(int(player.get_effective_move_speed()))],
		[_t("ui.player.stat_magnet"), str(int(player.get_magnet_bonus()))],
		[_stat_tag_row("ui.player.stat_tag_kesici", int(tag_counts.get("kesici", 0)))],
		[_stat_tag_row("ui.player.stat_tag_patlayici", int(tag_counts.get("patlayici", 0)))],
		[_stat_tag_row("ui.player.stat_tag_buyu", int(tag_counts.get("buyu", 0)))],
		[_stat_tag_row("ui.player.stat_tag_teknolojik", int(tag_counts.get("teknolojik", 0)))],
	]
	if player.overheal_shield > 0:
		stats_list.append([_t("ui.player.stat_overheal"), str(player.overheal_shield)])
	if player.bounce_timer > 0:
		stats_list.append([_t("ui.player.stat_bounce"), "%.1fs" % player.bounce_timer])
	if player.shrine_active:
		stats_list.append([_t("ui.player.stat_shrine"), "%.0fs" % player.shrine_timer])

	for stat in stats_list:
		var row := HBoxContainer.new()
		var lbl := Label.new()
		lbl.text = stat[0]
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl.add_theme_color_override("font_color", Color("#AAAAAA"))
		lbl.add_theme_font_size_override("font_size", 12)
		row.add_child(lbl)
		if stat[1] != "":
			var val := Label.new()
			val.text = stat[1]
			val.add_theme_color_override("font_color", Color("#FFFFFF"))
			val.add_theme_font_size_override("font_size", 12)
			row.add_child(val)
		vbox.add_child(row)
