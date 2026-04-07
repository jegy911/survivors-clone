extends Node

var wave_count = 0
var wave_timer = 0.0
var wave_interval = 60.0
var reward_active = false

var reaper_mode = false
var reaper_count = 0

var siege_active = false
var siege_timer = 0.0
var siege_cooldown_timer = 0.0
const SIEGE_DURATION = 120.0
const SIEGE_COOLDOWN = 60.0

var mini_boss_times = [300, 600, 900, 1200, 1500]
var next_mini_boss_index = 0

var main_node: Node = null
var wave_event_timer: float = 0.0
const WAVE_EVENT_INTERVAL: float = 180.0
const WAVE_EVENT_MIN_TIME: float = 120.0

func initialize(main: Node):
	main_node = main

func process(delta: float, game_timer: float):
	# Mini boss kontrolü
	if next_mini_boss_index < mini_boss_times.size():
		if game_timer >= mini_boss_times[next_mini_boss_index]:
			main_node.spawn_manager.spawn_mini_boss(game_timer, next_mini_boss_index)
			next_mini_boss_index += 1

	# 30. dakikada Reaper modu
	if game_timer >= 1800 and not reaper_mode:
		_start_reaper_mode(game_timer)

	# Reaper modunda sürekli spawn
	if reaper_mode:
		return

	# 15. dakikadan sonra siege sistemi
	if game_timer >= 900 and game_timer < 1800:
		if siege_active:
			siege_timer -= delta
			if siege_timer <= 0:
				siege_active = false
				siege_cooldown_timer = SIEGE_COOLDOWN
		else:
			siege_cooldown_timer -= delta
			if siege_cooldown_timer <= 0:
				siege_active = true
				siege_timer = SIEGE_DURATION
				_start_siege_wave()
				
	# Wave event sistemi
	if game_timer >= WAVE_EVENT_MIN_TIME and not reaper_mode and not siege_active:
		wave_event_timer += delta
		if wave_event_timer >= WAVE_EVENT_INTERVAL:
			wave_event_timer = 0.0
			if randf() < 0.60:
				main_node.spawn_manager.spawn_swarm_event(game_timer)
			else:
				main_node.spawn_manager.spawn_encircle_event(game_timer)
	# Her dakika wave artışı
	wave_timer += delta
	if wave_timer >= wave_interval:
		wave_timer = 0.0
		wave_count += 1
		_show_wave_reward()

func get_spawn_multiplier() -> float:
	return 3.0 if siege_active else 1.0

func get_interval_multiplier() -> float:
	return 0.3 if siege_active else 1.0

func _start_reaper_mode(game_timer: float):
	reaper_mode = true
	for enemy in EnemyRegistry.get_enemies():
		if not enemy.is_in_group("boss"):
			enemy.queue_free()
	var players = get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		players[0].show_floating_text("☠ ÖLÜM GELİYOR...", players[0].global_position + Vector2(0, -100), Color("#8B0000"), 28)
	await get_tree().create_timer(3.0).timeout
	_spawn_reaper_loop()

func _spawn_reaper_loop():
	if not reaper_mode:
		return
	reaper_count += 1
	var reaper = main_node.spawn_manager.spawn_reaper(reaper_count)
	var players = get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		players[0].show_floating_text("☠ REAPER #" + str(reaper_count), reaper.global_position + Vector2(0, -60), Color("#8B0000"), 20)
	reaper.tree_exited.connect(_on_reaper_died)

func _on_reaper_died():
	if not reaper_mode:
		return
	await get_tree().create_timer(2.0).timeout
	if reaper_mode:
		_spawn_reaper_loop()

func _start_siege_wave():
	var players = get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		players[0].show_floating_text("⚠ KUŞATMA!", players[0].global_position + Vector2(0, -80), Color("#FF6600"), 22)

func _show_wave_reward():
	reward_active = true
	get_tree().paused = true
	var overlay = CanvasLayer.new()
	overlay.name = "WaveRewardOverlay"
	main_node.add_child(overlay)
	overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.75)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(bg)
	var panel = PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(480, 320)
	panel.position -= Vector2(240, 160)
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#0D0D1A")
	style.border_color = Color("#9B59B6")
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	panel.add_theme_stylebox_override("panel", style)
	overlay.add_child(panel)
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 16)
	panel.add_child(vbox)
	var title = Label.new()
	title.text = "⚡ DALGA %d TAMAMLANDI!" % wave_count
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color("#9B59B6"))
	vbox.add_child(title)
	var sub = Label.new()
	sub.text = "Bir ödül seç:"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_color_override("font_color", Color("#AAAAAA"))
	vbox.add_child(sub)
	var hbox = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 12)
	vbox.add_child(hbox)
	var choices = _generate_reward_choices()
	for choice in choices:
		var btn = _make_reward_button(choice)
		btn.pressed.connect(func(): _on_reward_chosen(choice, overlay))
		hbox.add_child(btn)

func _generate_reward_choices() -> Array:
	var players = get_tree().get_nodes_in_group("player")
	var player = players[0] if not players.is_empty() else null
	var pool = [
		{"type": "gold", "amount": 30 + wave_count * 10, "label": "💰 Altın", "desc": "+%d Gold" % (30 + wave_count * 10), "color": "#FFD700"},
		{"type": "heal", "label": "💗 İyileşme", "desc": "Max HP'nin\n%25'ini yenile", "color": "#27AE60"},
		{"type": "item", "label": "🛡 Pasif Item", "desc": "Rastgele\npasif item", "color": "#3498DB"},
		{"type": "xp", "label": "⭐ Deneyim", "desc": "Anında\n+2 Level", "color": "#F39C12"},
	]
	if player and player.get("bullet_damage") != null:
		pool.append({"type": "damage", "label": "⚔ Güç", "desc": "+10 Hasar", "color": "#E74C3C"})
	pool.shuffle()
	return pool.slice(0, 3)

func _make_reward_button(choice: Dictionary) -> Button:
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(130, 90)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(choice["color"]).darkened(0.6)
	style.border_color = Color(choice["color"])
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.text = choice["label"] + "\n" + choice["desc"]
	return btn

func _on_reward_chosen(choice: Dictionary, overlay: Node):
	var players = get_tree().get_nodes_in_group("player")
	var player = players[0] if not players.is_empty() else null
	if player:
		match choice["type"]:
			"gold":
				player.gold_earned += choice["amount"]
				SaveManager.gold += choice["amount"]
				SaveManager.save_game()
			"heal":
				# Co-op: tüm oyuncuları iyileştir
				for p in players:
					var heal = int(p.max_hp * 0.25)
					p.hp = min(p.hp + heal, p.max_hp)
				EventBus.player_hp_changed.emit(player.hp, player.max_hp)
			"item":
				var items = ["lifesteal", "armor", "crit", "shield"]
				items.shuffle()
				player.add_item(items[0])
			"xp":
				# Co-op: tüm oyuncular XP kazanır
				for p in players:
					p.gain_xp(p.xp_to_next_level * 2)
			"damage":
				# Co-op: tüm oyuncular güçlenir
				for p in players:
					p.bullet_damage += 10
	overlay.queue_free()
	get_tree().paused = false
	reward_active = false
