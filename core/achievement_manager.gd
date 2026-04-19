extends Node

signal achievement_unlocked(achievement: Dictionary)

func check_after_game(run_kills: int, _survival_time: float):
	for ach in AchievementData.ACHIEVEMENTS:
		if SaveManager.unlocked_achievements.has(ach["id"]):
			continue
		var cond = ach["condition"]
		var unlocked = false
		match cond["type"]:
			"total_kills":
				unlocked = SaveManager.total_kills >= cond["amount"]
			"single_run_kills":
				unlocked = run_kills >= cond["amount"]
			"survival_time":
				unlocked = SaveManager.max_survival_time >= cond["amount"]
			"won_game":
				unlocked = SaveManager.total_wins >= cond["amount"]
			"total_bosses":
				unlocked = SaveManager.total_bosses_killed >= cond["amount"]
			"got_evolution":
				unlocked = SaveManager.evolution_obtained
			"unique_chars":
				unlocked = SaveManager.unique_chars_played.size() >= cond["amount"]
			"total_chests":
				unlocked = SaveManager.total_chests_opened >= cond["amount"]
			"total_gold":
				unlocked = SaveManager.total_gold_earned >= cond["amount"]
			"char_unlocked":
				unlocked = SaveManager.unlocked_characters.has(cond["char_id"])
		if unlocked:
			_unlock(ach)

func _unlock(ach: Dictionary):
	SaveManager.unlocked_achievements.append(ach["id"])
	SaveManager.gold += ach["reward_gold"]
	SaveManager.save_game()
	achievement_unlocked.emit(ach)
	_show_popup(ach)

func _show_popup(ach: Dictionary):
	var layer = CanvasLayer.new()
	layer.layer = 200
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child(layer)

	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(300, 70)
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#1A1A2E")
	style.border_color = Color("#FFD700")
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	panel.add_theme_stylebox_override("panel", style)
	layer.add_child(panel)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	panel.add_child(hbox)

	var icon = Label.new()
	icon.text = ach["icon"]
	icon.add_theme_font_size_override("font_size", 28)
	hbox.add_child(icon)

	var vbox = VBoxContainer.new()
	hbox.add_child(vbox)

	var title = Label.new()
	title.text = "🏅 Başarım: " + ach["name"]
	title.add_theme_color_override("font_color", Color("#FFD700"))
	title.add_theme_font_size_override("font_size", 14)
	vbox.add_child(title)

	var desc = Label.new()
	desc.text = ach["desc"] + " (+" + str(ach["reward_gold"]) + " 💰)"
	desc.add_theme_color_override("font_color", Color("#AAAAAA"))
	desc.add_theme_font_size_override("font_size", 11)
	vbox.add_child(desc)

	# Sağ üste konumlandır
	var vp = get_tree().root.get_viewport().get_visible_rect().size
	panel.position = Vector2(vp.x - 320, 20)

	# Animasyon: aşağı kayarak çıkar, bekler, kaybolur
	panel.modulate.a = 0.0
	var tween = panel.create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, 0.3)
	tween.tween_interval(3.0)
	tween.tween_property(panel, "modulate:a", 0.0, 0.5)
	tween.tween_callback(layer.queue_free)
