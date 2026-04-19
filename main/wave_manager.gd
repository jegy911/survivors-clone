extends Node

var wave_count: int = 0
var wave_timer: float = 0.0
var wave_interval: float = 60.0
var reward_active: bool = false

var reaper_mode: bool = false
var reaper_count: int = 0

var siege_active: bool = false
var siege_timer: float = 0.0
var siege_cooldown_timer: float = 0.0
const SIEGE_DURATION = 120.0
const SIEGE_COOLDOWN = 60.0

var mini_boss_times: Array = [300, 600, 900, 1200, 1500]
var next_mini_boss_index: int = 0

var main_node: Node = null
var wave_event_timer: float = 0.0
## Normal / fast story pacing; arena uses shorter cadence (tuned in `initialize`).
var _wave_event_interval: float = 180.0
var _run_goal_sec: float = 1800.0
var _wave_event_min_time: float = 120.0
var _siege_duration: float = 120.0
var _siege_cooldown: float = 60.0

func initialize(main: Node) -> void:
	main_node = main
	_run_goal_sec = SaveManager.get_run_goal_sec()
	mini_boss_times = SaveManager.get_mini_boss_times()
	_wave_event_min_time = maxf(72.0, 120.0 * (_run_goal_sec / 1800.0))
	_wave_event_interval = 180.0
	wave_interval = 60.0
	_siege_duration = SIEGE_DURATION
	_siege_cooldown = SIEGE_COOLDOWN
	if SaveManager.is_arena_run():
		# ~10 min goal: denser mid-run pressure vs story (30 min).
		wave_interval = 42.0
		_wave_event_interval = 95.0
		_wave_event_min_time = maxf(38.0, 72.0 * (_run_goal_sec / 1800.0))
		_siege_duration = 88.0
		_siege_cooldown = 44.0

func process(delta: float, game_timer: float) -> void:
	# Mini boss kontrolü
	if next_mini_boss_index < mini_boss_times.size():
		if game_timer >= mini_boss_times[next_mini_boss_index]:
			main_node.spawn_manager.spawn_mini_boss(game_timer, next_mini_boss_index)
			next_mini_boss_index += 1

	# Reaper — hedef süre (hikâye 30 dk / hızlı ~14 dk)
	if game_timer >= _run_goal_sec and not reaper_mode:
		_start_reaper_mode(game_timer)

	# Reaper modunda sürekli spawn
	if reaper_mode:
		return

	var half_goal: float = _run_goal_sec * 0.5
	if game_timer >= half_goal and game_timer < _run_goal_sec:
		if siege_active:
			siege_timer -= delta
			if siege_timer <= 0:
				siege_active = false
				siege_cooldown_timer = _siege_cooldown
		else:
			siege_cooldown_timer -= delta
			if siege_cooldown_timer <= 0:
				siege_active = true
				siege_timer = _siege_duration
				_start_siege_wave()
				
	# Wave event sistemi
	if game_timer >= _wave_event_min_time and not reaper_mode and not siege_active:
		wave_event_timer += delta
		if wave_event_timer >= _wave_event_interval:
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
	if siege_active:
		return 3.35 if SaveManager.is_arena_run() else 3.0
	return 1.38 if SaveManager.is_arena_run() else 1.0

func get_interval_multiplier() -> float:
	if siege_active:
		return 0.24 if SaveManager.is_arena_run() else 0.3
	return 1.0

func _start_reaper_mode(_game_timer: float) -> void:
	reaper_mode = true
	for enemy in EnemyRegistry.get_enemies():
		if not enemy.is_in_group("boss"):
			enemy.queue_free()
	var players = get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		players[0].show_floating_text(tr("ui.alerts.reaper_approaching"), players[0].global_position + Vector2(0, -100), Color("#8B0000"), 28)
	await get_tree().create_timer(3.0).timeout
	_spawn_reaper_loop()

func _spawn_reaper_loop() -> void:
	if not reaper_mode:
		return
	reaper_count += 1
	var reaper = main_node.spawn_manager.spawn_reaper(reaper_count)
	var players = get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		players[0].show_floating_text(tr("ui.alerts.reaper_spawned") % reaper_count, reaper.global_position + Vector2(0, -60), Color("#8B0000"), 20)
	reaper.tree_exited.connect(_on_reaper_died)

func _on_reaper_died() -> void:
	if not reaper_mode:
		return
	await get_tree().create_timer(2.0).timeout
	if reaper_mode:
		_spawn_reaper_loop()

func _start_siege_wave() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		players[0].show_floating_text(tr("ui.alerts.siege"), players[0].global_position + Vector2(0, -80), Color("#FF6600"), 22)

func _show_wave_reward() -> void:
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
	title.text = tr("ui.wave_reward.title") % wave_count
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color("#9B59B6"))
	vbox.add_child(title)
	var sub = Label.new()
	sub.text = tr("ui.wave_reward.pick_prompt")
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
	var gold_amt: int = 12 + wave_count * 4
	var pool = [
		{"type": "gold", "amount": gold_amt, "label": tr("ui.wave_reward.gold_label"), "desc": tr("ui.wave_reward.gold_desc") % gold_amt, "color": "#FFD700"},
		{"type": "heal", "label": tr("ui.wave_reward.heal_label"), "desc": tr("ui.wave_reward.heal_desc") % 15, "color": "#27AE60"},
		{"type": "item", "label": tr("ui.wave_reward.item_label"), "desc": tr("ui.wave_reward.item_desc"), "color": "#3498DB"},
		{"type": "xp", "label": tr("ui.wave_reward.xp_label"), "desc": tr("ui.wave_reward.xp_desc"), "color": "#F39C12"},
	]
	if player and player.get("bullet_damage") != null:
		pool.append({"type": "damage", "amount": 5, "label": tr("ui.wave_reward.damage_label"), "desc": tr("ui.wave_reward.damage_desc") % 5, "color": "#E74C3C"})
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

func _on_reward_chosen(choice: Dictionary, overlay: Node) -> void:
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
					var heal = int(p.max_hp * 0.15)
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
					p.bullet_damage += int(choice.get("amount", 5))
	overlay.queue_free()
	get_tree().paused = false
	reward_active = false
