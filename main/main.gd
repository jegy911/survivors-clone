extends Node2D

var spawn_timer = 0.0
var spawn_interval = 3.0
var enemies_per_wave = 2
var immunity_timer = 0.0
var current_immunity = ""
const IMMUNITY_INTERVAL = 180.0
const IMMUNITY_TYPES = ["fire", "ice", "lightning"]
var game_timer = 0.0
var hit_stop_frames = 0

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
	EventBus.game_started.emit()
	EventBus.hit_stop_requested.connect(_on_hit_stop_requested)

func _load_player():
	_spawn_player(0, Vector2(-50, 0))
	_spawn_player(1, Vector2(50, 0))

func _spawn_player(id: int, offset: Vector2):
	var char_id = CharacterData.CHARACTERS[SaveManager.selected_character]["id"]
	var scene_path = "res://characters/warrior/warrior.tscn"
	match char_id:
		"warrior": scene_path = "res://characters/warrior/warrior.tscn"
		"mage": scene_path = "res://characters/mage/mage.tscn"
		"vampire": scene_path = "res://characters/vampire/vampire.tscn"
		"hunter": scene_path = "res://characters/hunter/hunter.tscn"
		"stormer": scene_path = "res://characters/stormer/stormer.tscn"
		"frost": scene_path = "res://characters/frost/frost.tscn"
		"shadow_walker": scene_path = "res://characters/shadow_walker/shadow_walker.tscn"
		"engineer": scene_path = "res://characters/engineer/engineer.tscn"
		"paladin": scene_path = "res://characters/paladin/paladin.tscn"
		"blood_prince": scene_path = "res://characters/blood_prince/blood_prince.tscn"
		"death_knight": scene_path = "res://characters/death_knight/death_knight.tscn"
		"chaos": scene_path = "res://characters/chaos/chaos.tscn"
		"omega": scene_path = "res://characters/omega/omega.tscn"
		_: scene_path = "res://characters/warrior/warrior.tscn"
	var player_scene = load(scene_path)
	var player = player_scene.instantiate()
	player.add_to_group("player")
	player.set_player_id(id)
	player.position = offset
	add_child(player)

func _on_hit_stop_requested(frames: int):
	hit_stop_frames = max(hit_stop_frames, frames)

func get_curse_level() -> int:
	return SaveManager.meta_upgrades.get("curse_level", 0)

func get_effective_spawn_interval() -> float:
	var curse = get_curse_level()
	return max(0.2, spawn_interval * (1.0 - curse * 0.10))

func get_effective_enemies_per_wave() -> int:
	return enemies_per_wave + get_curse_level()

func _process(delta):
	if hit_stop_frames > 0:
		Engine.time_scale = 0.0
		hit_stop_frames -= 1
		return
	else:
		Engine.time_scale = 1.0

	game_timer += delta
	_update_camera(delta)
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
		var current_count = get_tree().get_nodes_in_group("enemies").size()
		if current_count < spawn_manager.MAX_ENEMIES:
			var to_spawn = get_effective_enemies_per_wave() * wave_manager.get_spawn_multiplier()
			var can_spawn = min(to_spawn, spawn_manager.MAX_ENEMIES - current_count)
			for i in can_spawn:
				spawn_manager.spawn_random_enemy(game_timer, current_immunity)
			# Wave artışı
			if wave_manager.wave_count > 0:
				enemies_per_wave = 2 + wave_manager.wave_count * 2
				spawn_interval = max(0.2, 3.0 - wave_manager.wave_count * 0.08)
		spawn_timer = get_effective_spawn_interval() * wave_manager.get_interval_multiplier()

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
