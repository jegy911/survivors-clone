extends Node2D

var spawn_timer = 0.0
var immunity_timer = 0.0
var current_immunity = ""
const IMMUNITY_INTERVAL = 180.0
const IMMUNITY_TYPES = ["fire", "ice", "lightning"]
var game_timer = 0.0
var hit_stop_frames = 0
var upgrade_queue: Array = []
var upgrade_processing: bool = false

@onready var timer_label = $HUD/TimerLabel
@onready var wave_label = $HUD/WaveLabel

var spawn_manager: Node = null
var wave_manager: Node = null
var env_manager: Node = null

func _ready():
	randomize()
	add_to_group("main")
	# Managers oluştur
	spawn_manager = load("res://main/spawn_manager.gd").new()
	wave_manager = load("res://main/wave_manager.gd").new()
	env_manager = load("res://main/environment_manager.gd").new()
	add_child(spawn_manager)
	add_child(wave_manager)
	add_child(env_manager)
	spawn_manager.initialize(self)
	wave_manager.initialize(self)
	env_manager.initialize(self)
	_load_player()
	_setup_camera()
	_setup_coop_hud()
	EventBus.game_started.emit()
	EventBus.hit_stop_requested.connect(_on_hit_stop_requested)

func _load_player():
	_spawn_player(0, Vector2(0, 0))
	if SaveManager.game_mode == "local_coop":
		_spawn_player(1, Vector2(60, 0))

func _spawn_player(id: int, offset: Vector2):
	var char_index = SaveManager.selected_character if id == 0 else SaveManager.selected_character_p2
	var char_id = CharacterData.CHARACTERS[char_index]["id"]
	var scene_path = _get_character_scene(char_id)
	var player_scene = load(scene_path)
	var player = player_scene.instantiate()
	player.add_to_group("player")
	player.set_player_id(id)
	player.position = offset
	add_child(player)

func _get_character_scene(char_id: String) -> String:
	return CharacterData.get_character_scene_path(char_id)

func _on_hit_stop_requested(frames: int):
	hit_stop_frames = max(hit_stop_frames, frames)

func get_curse_level() -> int:
	return SaveManager.meta_upgrades.get("curse_level", 0)


func _process(delta):
	if hit_stop_frames > 0:
		Engine.time_scale = 0.0
		hit_stop_frames -= 1
		return
	else:
		Engine.time_scale = 1.0

	game_timer += delta
	_update_camera(delta)
	_update_coop_hud()
	update_timer_label()

	if game_timer >= 900 and AudioManager.current_music == 1:
		AudioManager.play_music(2)

	# Bağışıklık rotasyonu
	if game_timer <= 900:
		immunity_timer = 0.0
		current_immunity = ""
	else:
		immunity_timer += delta
		if immunity_timer >= IMMUNITY_INTERVAL:
			immunity_timer = 0.0
			current_immunity = IMMUNITY_TYPES[randi() % IMMUNITY_TYPES.size()]
			spawn_manager.apply_immunity_to_existing(current_immunity)
			var players = get_tree().get_nodes_in_group("player")
			if not players.is_empty():
				players[0].show_floating_text("⚠ BAĞIŞIKLIK: " + current_immunity.to_upper(), players[0].global_position + Vector2(0, -80), Color("#FF6600"), 18)

	# Wave ve reaper yönetimi
	wave_manager.process(delta, game_timer)

	# Reaper modunda spawn yok
	if wave_manager.reaper_mode:
		spawn_timer -= delta
		if spawn_timer <= 0:
			spawn_timer = 8.0
			spawn_manager.spawn_reaper(wave_manager.reaper_count)
		return

	# Environment
	env_manager.process(delta)

	# Spawn
	spawn_timer -= delta
	if spawn_timer <= 0:
		var current_count = EnemyRegistry.get_live_count()
		var min_enemies = spawn_manager.get_current_min_enemies(game_timer)
		if current_count < spawn_manager.MAX_ENEMIES:
			var to_spawn = int(wave_manager.get_spawn_multiplier())
			if current_count < min_enemies:
				to_spawn = max(to_spawn, min_enemies - current_count)
			var can_spawn = min(to_spawn, spawn_manager.MAX_ENEMIES - current_count)
			for i in can_spawn:
				spawn_manager.spawn_random_enemy(game_timer, current_immunity)
		spawn_timer = spawn_manager.get_current_spawn_interval(game_timer) * wave_manager.get_interval_multiplier()

func update_timer_label():
	if timer_label == null or wave_label == null:
		return
	var minutes = int(game_timer) / 60
	var seconds = int(game_timer) % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]
	if game_timer < 1800.0:
		timer_label.add_theme_color_override("font_color", Color("#FFFFFF"))
		timer_label.add_theme_font_size_override("font_size", 18)
	else:
		timer_label.add_theme_color_override("font_color", Color("#8B0000"))
		timer_label.add_theme_font_size_override("font_size", 24)
	wave_label.text = "Dalga: " + str(wave_manager.wave_count)
	
var main_camera: Camera2D = null
var coop_hud: CanvasLayer = null
const MIN_ZOOM = 0.5
const MAX_ZOOM = 1.2
const ZOOM_SPEED = 2.0
const CAMERA_SPEED = 5.0

func _setup_camera():
	main_camera = Camera2D.new()
	main_camera.enabled = true
	main_camera.position_smoothing_enabled = true
	main_camera.position_smoothing_speed = CAMERA_SPEED
	add_child(main_camera)
	

func _setup_coop_hud():
	if SaveManager.game_mode != "local_coop":
		return
	coop_hud = CanvasLayer.new()
	coop_hud.layer = 10
	add_child(coop_hud)

	var screen_size = get_viewport().get_visible_rect().size

	# P1 HUD — sol üst
	var p1_panel = _make_hud_panel(Vector2(10, 10), Color("#27AE60"), "P1")
	coop_hud.add_child(p1_panel)

	# P2 HUD — sağ üst
	var p2_panel = _make_hud_panel(Vector2(screen_size.x - 210, 10), Color("#2471A3"), "P2")
	coop_hud.add_child(p2_panel)

func _make_hud_panel(pos: Vector2, color: Color, label: String) -> PanelContainer:
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(200, 100)
	panel.position = pos
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#0D0D1ACC")
	style.border_color = color
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	panel.add_theme_stylebox_override("panel", style)
	panel.name = label + "_panel"

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	panel.add_child(vbox)

	# Oyuncu etiketi
	var player_label = Label.new()
	player_label.text = label
	player_label.add_theme_color_override("font_color", color)
	player_label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(player_label)

	# HP bar arka plan
	var hp_bg = ColorRect.new()
	hp_bg.name = "HPBarBG"
	hp_bg.custom_minimum_size = Vector2(180, 12)
	hp_bg.color = Color("#333333")
	vbox.add_child(hp_bg)

	# HP bar dolu
	var hp_fill = ColorRect.new()
	hp_fill.name = "HPBarFill"
	hp_fill.size = Vector2(180, 12)
	hp_fill.position = hp_bg.position
	hp_fill.color = Color("#2ECC71")
	hp_bg.add_child(hp_fill)

	# Level ve kill
	var stats_row = HBoxContainer.new()
	stats_row.name = "StatsRow"
	stats_row.add_theme_constant_override("separation", 10)
	vbox.add_child(stats_row)

	var level_label = Label.new()
	level_label.name = "LevelLabel"
	level_label.text = "Lv 1"
	level_label.add_theme_color_override("font_color", Color("#FFD700"))
	level_label.add_theme_font_size_override("font_size", 12)
	stats_row.add_child(level_label)

	var kill_label = Label.new()
	kill_label.name = "KillLabel"
	kill_label.text = "💀 0"
	kill_label.add_theme_color_override("font_color", Color("#AAAAAA"))
	kill_label.add_theme_font_size_override("font_size", 12)
	stats_row.add_child(kill_label)

	# XP bar
	var xp_bar = ProgressBar.new()
	xp_bar.name = "XPBar"
	xp_bar.custom_minimum_size = Vector2(180, 6)
	xp_bar.show_percentage = false
	xp_bar.max_value = 30
	xp_bar.value = 0
	var xp_style = StyleBoxFlat.new()
	xp_style.bg_color = Color("#4A90E2")
	xp_bar.add_theme_stylebox_override("fill", xp_style)
	vbox.add_child(xp_bar)

	return panel

func _update_coop_hud():
	if SaveManager.game_mode != "local_coop" or coop_hud == null:
		return
	var players = get_tree().get_nodes_in_group("player")
	for p in players:
		var panel_name = "P1_panel" if p.player_id == 0 else "P2_panel"
		var panel = coop_hud.get_node_or_null(panel_name)
		if panel == null:
			continue
		var vbox = panel.get_child(0)
		# HP bar
		var hp_bg = vbox.get_node_or_null("HPBarBG")
		if hp_bg:
			var hp_fill = hp_bg.get_node_or_null("HPBarFill")
			if hp_fill:
				var ratio = float(p.hp) / float(p.max_hp)
				hp_fill.size.x = 180 * ratio
				if ratio > 0.5:
					hp_fill.color = Color("#2ECC71")
				elif ratio > 0.25:
					hp_fill.color = Color("#F39C12")
				else:
					hp_fill.color = Color("#E74C3C")
		# Level
		var stats_row = vbox.get_node_or_null("StatsRow")
		if stats_row:
			var level_label = stats_row.get_node_or_null("LevelLabel")
			if level_label:
				level_label.text = "Lv " + str(p.level)
			var kill_label = stats_row.get_node_or_null("KillLabel")
			if kill_label:
				kill_label.text = "💀 " + str(p.kill_count)
		# XP bar
		var xp_bar = vbox.get_node_or_null("XPBar")
		if xp_bar:
			xp_bar.max_value = p.xp_to_next_level
			xp_bar.value = p.xp

func _update_camera(delta: float):
	var players = get_tree().get_nodes_in_group("player")
	if players.is_empty() or main_camera == null:
		return
	
	# Tüm oyuncuların ortasını hesapla
	var center = Vector2.ZERO
	for p in players:
		center += p.global_position
	center /= players.size()
	main_camera.global_position = center
	
	# Oyuncular arası max mesafeye göre zoom ayarla
	if players.size() <= 1:
		main_camera.zoom = lerp(main_camera.zoom, Vector2(MAX_ZOOM, MAX_ZOOM), delta * ZOOM_SPEED)
		return
	
	var max_dist = 0.0
	for p in players:
		var dist = center.distance_to(p.global_position)
		if dist > max_dist:
			max_dist = dist
	
	# Oyuncular arası max mesafe sınırı
	const MAX_PLAYER_DISTANCE = 600.0
	if max_dist > MAX_PLAYER_DISTANCE:
		for p in players:
			var dir = (p.global_position - center).normalized()
			p.global_position = center + dir * MAX_PLAYER_DISTANCE
	
	var screen_size = get_viewport().get_visible_rect().size
	var target_zoom = clamp(
		screen_size.x / (max_dist * 4.0 + screen_size.x),
		MIN_ZOOM,
		MAX_ZOOM
	)
	main_camera.zoom = lerp(main_camera.zoom, Vector2(target_zoom, target_zoom), delta * ZOOM_SPEED)

func queue_upgrade(player: Node):
	if SaveManager.game_mode != "local_coop":
		return
	upgrade_queue.append(player)
	if not upgrade_processing:
		_process_next_upgrade()

func _process_next_upgrade():
	if upgrade_queue.is_empty():
		upgrade_processing = false
		get_tree().paused = false
		return
	upgrade_processing = true
	get_tree().paused = true
	var player = upgrade_queue.pop_front()
	if not is_instance_valid(player):
		_process_next_upgrade()
		return
	var upgrade_ui = load("res://ui/upgrade_ui.tscn").instantiate()
	upgrade_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child(upgrade_ui)
	upgrade_ui.upgrade_chosen.connect(func(id):
		player._on_upgrade_chosen(id)
		upgrade_ui.queue_free()
		_process_next_upgrade()
	)
	upgrade_ui.show_upgrades(player)
