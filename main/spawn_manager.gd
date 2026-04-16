extends Node

var enemy_scene = preload("res://enemies/enemy.tscn")
var fast_enemy_scene = preload("res://enemies/fast_enemy.tscn")
var tank_enemy_scene = preload("res://enemies/tank_enemy.tscn")
var ranged_enemy_scene = preload("res://enemies/ranged_enemy.tscn")
var boss_scene = preload("res://enemies/boss.tscn")
var exploder_scene = preload("res://enemies/exploder.tscn")
var dasher_scene = preload("res://enemies/dasher.tscn")
var healer_scene = preload("res://enemies/healer.tscn")
var shield_enemy_scene = preload("res://enemies/shield_enemy.tscn")
var giant_scene = preload("res://enemies/giant.tscn")

const ELITE_CHANCE = 0.15

var main_node: Node = null

# VS tarzı wave tablosu
# Her dakika: { "enemies": [...], "min": int, "interval": float }
# enemies listesinde her eleman: { "scene": string, "weight": float }
const WAVE_TABLE = {
	0:  {"enemies": [{"scene": "enemy", "weight": 1.0}], "min": 2, "interval": 3.0},
	1:  {"enemies": [{"scene": "enemy", "weight": 1.0}], "min": 5, "interval": 2.5},
	2:  {"enemies": [{"scene": "enemy", "weight": 0.7}, {"scene": "fast_enemy", "weight": 0.3}], "min": 8, "interval": 2.0},
	3:  {"enemies": [{"scene": "fast_enemy", "weight": 0.6}, {"scene": "enemy", "weight": 0.4}], "min": 10, "interval": 1.8},
	4:  {"enemies": [{"scene": "fast_enemy", "weight": 0.5}, {"scene": "dasher", "weight": 0.5}], "min": 12, "interval": 1.5},
	5:  {"enemies": [{"scene": "fast_enemy", "weight": 0.4}, {"scene": "dasher", "weight": 0.6}], "min": 15, "interval": 1.5},
	6:  {"enemies": [{"scene": "dasher", "weight": 0.5}, {"scene": "tank", "weight": 0.3}, {"scene": "fast_enemy", "weight": 0.2}], "min": 15, "interval": 1.2},
	7:  {"enemies": [{"scene": "tank", "weight": 0.4}, {"scene": "dasher", "weight": 0.4}, {"scene": "healer", "weight": 0.2}], "min": 18, "interval": 1.2},
	8:  {"enemies": [{"scene": "tank", "weight": 0.3}, {"scene": "dasher", "weight": 0.3}, {"scene": "healer", "weight": 0.2}, {"scene": "fast_enemy", "weight": 0.2}], "min": 20, "interval": 1.0},
	9:  {"enemies": [{"scene": "exploder", "weight": 0.3}, {"scene": "tank", "weight": 0.3}, {"scene": "dasher", "weight": 0.2}, {"scene": "healer", "weight": 0.2}], "min": 20, "interval": 1.0},
	10: {"enemies": [{"scene": "exploder", "weight": 0.25}, {"scene": "tank", "weight": 0.25}, {"scene": "shield", "weight": 0.25}, {"scene": "healer", "weight": 0.25}], "min": 22, "interval": 0.9},
	11: {"enemies": [{"scene": "exploder", "weight": 0.2}, {"scene": "shield", "weight": 0.3}, {"scene": "tank", "weight": 0.2}, {"scene": "dasher", "weight": 0.3}], "min": 25, "interval": 0.9},
	12: {"enemies": [{"scene": "shield", "weight": 0.3}, {"scene": "exploder", "weight": 0.3}, {"scene": "healer", "weight": 0.2}, {"scene": "tank", "weight": 0.2}], "min": 25, "interval": 0.8},
	13: {"enemies": [{"scene": "shield", "weight": 0.3}, {"scene": "exploder", "weight": 0.2}, {"scene": "dasher", "weight": 0.3}, {"scene": "healer", "weight": 0.2}], "min": 28, "interval": 0.8},
	14: {"enemies": [{"scene": "giant", "weight": 0.2}, {"scene": "shield", "weight": 0.3}, {"scene": "exploder", "weight": 0.3}, {"scene": "healer", "weight": 0.2}], "min": 28, "interval": 0.7},
	15: {"enemies": [{"scene": "giant", "weight": 0.3}, {"scene": "shield", "weight": 0.2}, {"scene": "exploder", "weight": 0.3}, {"scene": "ranged", "weight": 0.2}], "min": 30, "interval": 0.7},
	16: {"enemies": [{"scene": "giant", "weight": 0.3}, {"scene": "ranged", "weight": 0.3}, {"scene": "shield", "weight": 0.2}, {"scene": "healer", "weight": 0.2}], "min": 30, "interval": 0.6},
	17: {"enemies": [{"scene": "giant", "weight": 0.3}, {"scene": "ranged", "weight": 0.3}, {"scene": "exploder", "weight": 0.2}, {"scene": "tank", "weight": 0.2}], "min": 32, "interval": 0.6},
	18: {"enemies": [{"scene": "giant", "weight": 0.4}, {"scene": "ranged", "weight": 0.3}, {"scene": "shield", "weight": 0.3}], "min": 35, "interval": 0.5},
	19: {"enemies": [{"scene": "giant", "weight": 0.4}, {"scene": "ranged", "weight": 0.3}, {"scene": "exploder", "weight": 0.3}], "min": 35, "interval": 0.5},
	20: {"enemies": [{"scene": "giant", "weight": 0.3}, {"scene": "ranged", "weight": 0.3}, {"scene": "shield", "weight": 0.2}, {"scene": "exploder", "weight": 0.2}], "min": 40, "interval": 0.4},
}

func initialize(main: Node) -> void:
	main_node = main


func get_max_enemies() -> int:
	return SaveManager.get_max_enemies_cap()

func _get_wave_data(game_timer: float) -> Dictionary:
	var minute = int(game_timer / 60.0)
	minute = min(minute, 20)
	return WAVE_TABLE[minute]

func _scene_from_name(name: String) -> PackedScene:
	match name:
		"enemy": return enemy_scene
		"fast_enemy": return fast_enemy_scene
		"tank": return tank_enemy_scene
		"ranged": return ranged_enemy_scene
		"exploder": return exploder_scene
		"dasher": return dasher_scene
		"healer": return healer_scene
		"shield": return shield_enemy_scene
		"giant": return giant_scene
		_: return enemy_scene

func _pick_from_wave(wave: Dictionary) -> Node:
	var enemies = wave["enemies"]
	var total = 0.0
	for e in enemies:
		total += e["weight"]
	var roll = randf() * total
	var cumulative = 0.0
	for e in enemies:
		cumulative += e["weight"]
		if roll <= cumulative:
			return _scene_from_name(e["scene"]).instantiate()
	return enemy_scene.instantiate()

func get_current_spawn_interval(game_timer: float) -> float:
	var wave = _get_wave_data(game_timer)
	var meta_curse: int = int(SaveManager.meta_upgrades.get("curse_level", 0))
	# Meta curse and run curse tier stack: each tier +10% spawn frequency (shorter interval).
	var spawn_pressure: float = (1.0 + meta_curse * 0.10) * SaveManager.get_run_spawn_difficulty_mult()
	var interval: float = max(0.15, wave["interval"] / spawn_pressure)
	if SaveManager.is_arena_run():
		interval /= 1.22
	return interval

func get_current_min_enemies(game_timer: float) -> int:
	var wave = _get_wave_data(game_timer)
	var curse: int = int(SaveManager.meta_upgrades.get("curse_level", 0))
	var n: int = wave["min"] + curse * 2
	if SaveManager.is_arena_run():
		n = int(ceili(float(n) * 1.12))
	return n

func get_spawn_outside_screen() -> Vector2:
	var players = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return Vector2.ZERO
	var center = Vector2.ZERO
	for p in players:
		center += p.global_position
	center /= players.size()
	var screen_size = get_viewport().get_visible_rect().size
	var half_w = screen_size.x / 2 + 80
	var half_h = screen_size.y / 2 + 80
	var side = randi() % 4
	var pos = Vector2.ZERO
	match side:
		0: pos = Vector2(randf_range(-half_w, half_w), -half_h)
		1: pos = Vector2(randf_range(-half_w, half_w), half_h)
		2: pos = Vector2(-half_w, randf_range(-half_h, half_h))
		3: pos = Vector2(half_w, randf_range(-half_h, half_h))
	return center + pos

func spawn_random_enemy(game_timer: float, current_immunity: String) -> void:
	var wave = _get_wave_data(game_timer)
	var enemy = _pick_from_wave(wave)
	if enemy == null:
		return
	main_node.add_child(enemy)
	enemy.global_position = get_spawn_outside_screen()
	_apply_scaling(enemy, game_timer)
	_apply_meta_curse_level(enemy)
	_apply_run_curse_tier(enemy)
	_make_elite(enemy, game_timer)
	if current_immunity != "" and randf() < 0.30:
		_apply_immunity(enemy, current_immunity)

func spawn_mini_boss(game_timer: float, boss_index: int) -> void:
	EventBus.boss_spawned.emit()
	var boss = boss_scene.instantiate()
	boss.set_meta("codex_id", "mini_boss")
	main_node.add_child(boss)
	boss.global_position = get_spawn_outside_screen()
	if boss.get("hp") != null:
		boss.hp = int(boss.hp * (1.0 + boss_index * 0.3))
		boss.max_hp = boss.hp
	if boss.get("DAMAGE") != null:
		boss.DAMAGE = int(boss.DAMAGE * (1.0 + boss_index * 0.2))
	_apply_run_curse_tier(boss)

func spawn_reaper(reaper_count: int) -> Node:
	var reaper = boss_scene.instantiate()
	reaper.set_meta("codex_id", "reaper")
	main_node.add_child(reaper)
	reaper.global_position = get_spawn_outside_screen()
	var mult = 1.0 + reaper_count * 0.5
	if reaper.get("hp") != null:
		reaper.hp = int(500 * mult * 3)
		reaper.max_hp = reaper.hp
	if reaper.get("DAMAGE") != null:
		reaper.DAMAGE = int(80 * mult)
	if reaper.get("BASE_SPEED") != null:
		reaper.BASE_SPEED = 90.0 + reaper_count * 5.0
		reaper.current_speed = reaper.BASE_SPEED
	if reaper.get_node_or_null("ColorRect"):
		reaper.get_node("ColorRect").color = Color("#1A0000")
	_apply_run_curse_tier(reaper)
	return reaper

func _apply_scaling(enemy: Node, game_timer: float) -> void:
	var minutes = game_timer / 60.0
	var hp_mult = 1.0 + minutes * 0.05
	var dmg_mult = 1.0 + minutes * 0.04
	var spd_mult = 1.0 + minutes * 0.005
	if enemy.get("hp") != null:
		enemy.hp = int(enemy.hp * hp_mult)
		enemy.max_hp = enemy.hp
	if enemy.get("DAMAGE") != null:
		enemy.DAMAGE = int(enemy.DAMAGE * dmg_mult)
	if enemy.get("BASE_SPEED") != null:
		enemy.BASE_SPEED *= spd_mult

func _apply_meta_curse_level(enemy: Node) -> void:
	var curse: int = int(SaveManager.meta_upgrades.get("curse_level", 0))
	if curse <= 0:
		return
	var hp_mult: float = 1.0 + curse * 0.10
	var speed_mult: float = 1.0 + curse * 0.05
	if enemy.get("hp") != null:
		enemy.hp = int(enemy.hp * hp_mult)
		enemy.max_hp = enemy.hp
	if enemy.get("BASE_SPEED") != null:
		enemy.BASE_SPEED *= speed_mult


## `SaveManager.settings["run_curse_tier"]` (0–5): +10% HP, +5% move speed per tier (map_select).
func _apply_run_curse_tier(enemy: Node) -> void:
	var tier: int = SaveManager.get_run_curse_tier()
	if tier <= 0:
		return
	var hp_m: float = 1.0 + 0.10 * float(tier)
	var spd_m: float = 1.0 + 0.05 * float(tier)
	if enemy.get("hp") != null:
		enemy.hp = int(round(float(enemy.hp) * hp_m))
		enemy.max_hp = enemy.hp
	if enemy.get("BASE_SPEED") != null:
		enemy.BASE_SPEED *= spd_m

func _make_elite(enemy: Node, game_timer: float) -> void:
	if game_timer < 60:
		return
	if randf() > ELITE_CHANCE:
		return
	if enemy.get("hp") != null:
		enemy.hp = int(enemy.hp * 2.0)
		enemy.max_hp = enemy.hp
	if enemy.get("DAMAGE") != null:
		enemy.DAMAGE = int(enemy.DAMAGE * 1.5)
	if enemy.get("BASE_SPEED") != null:
		enemy.BASE_SPEED *= 1.2
	if enemy.get("XP_VALUE") != null:
		enemy.XP_VALUE = int(enemy.XP_VALUE * 3.0)
	enemy.set_meta("is_elite", true)
	var border = ColorRect.new()
	border.color = Color(0.2, 0.5, 1.0, 0.4)
	border.size = Vector2(44, 44)
	border.position = Vector2(-22, -22)
	border.z_index = -1
	enemy.add_child(border)
	var tween = border.create_tween()
	tween.set_loops()
	tween.tween_property(border, "modulate:a", 1.0, 0.5)
	tween.tween_property(border, "modulate:a", 0.3, 0.5)

func _apply_immunity(enemy: Node, immunity_type: String) -> void:
	enemy.set_meta("immunity", immunity_type)
	var indicator = ColorRect.new()
	indicator.name = "ImmunityIndicator"
	var color = Color("#FF4500") if immunity_type == "fire" else (Color("#00BFFF") if immunity_type == "ice" else Color("#FFD700"))
	indicator.color = color
	indicator.modulate.a = 0.4
	indicator.size = Vector2(enemy.body.size.x + 8, enemy.body.size.y + 8) if enemy.get_node_or_null("ColorRect") else Vector2(24, 24)
	indicator.position = Vector2(-4, -4)
	indicator.z_index = -1
	enemy.add_child(indicator)

func apply_immunity_to_existing(current_immunity: String) -> void:
	var enemies = EnemyRegistry.get_enemies()
	for enemy in enemies:
		if randf() < 0.30:
			_apply_immunity(enemy, current_immunity)

func spawn_swarm_event(game_timer: float) -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return
	var center = Vector2.ZERO
	for p in players:
		center += p.global_position
	center /= players.size()

	var from_right = randf() > 0.5
	var direction = Vector2(-1, 0) if from_right else Vector2(1, 0)
	var spawn_x = center.x + (900 if from_right else -900)
	# Daha kalabalık sürü; arena’da ekstra baskı (performans çarpanı hâlâ geçerli).
	var count = int((58 + randi() % 38) * SaveManager.get_swarm_event_count_mult())
	if SaveManager.is_arena_run():
		count = int(round(float(count) * 1.55))
	count = maxi(count, 16)

	for i in count:
		var current_count = EnemyRegistry.get_live_count()
		if current_count >= get_max_enemies():
			break
		var enemy = _pick_swarm_scene().instantiate()
		main_node.add_child(enemy)
		var screen_h = get_viewport().get_visible_rect().size.y
		enemy.global_position = Vector2(spawn_x, center.y + randf_range(-screen_h * 0.6, screen_h * 0.6))
		_apply_scaling(enemy, game_timer)
		_apply_meta_curse_level(enemy)
		_apply_run_curse_tier(enemy)
		enemy.make_swarm_enemy(direction, randf_range(160.0, 220.0))

	players[0].show_floating_text(
		tr("ui.alerts.swarm_incoming"),
		players[0].global_position + Vector2(0, -90),
		Color("#FF6600"), 20
	)

func spawn_encircle_event(game_timer: float) -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return
	var center = Vector2.ZERO
	for p in players:
		center += p.global_position
	center /= players.size()

	var count = int((16 + randi() % 9) * SaveManager.get_encircle_event_count_mult())
	count = maxi(count, 6)
	var radius = 650.0

	for i in count:
		var current_count = EnemyRegistry.get_live_count()
		if current_count >= get_max_enemies():
			break
		var angle = (TAU / count) * i
		var enemy = tank_enemy_scene.instantiate()
		main_node.add_child(enemy)
		enemy.global_position = center + Vector2(cos(angle), sin(angle)) * radius
		_apply_scaling(enemy, game_timer)
		_apply_meta_curse_level(enemy)
		_apply_run_curse_tier(enemy)

	players[0].show_floating_text(
		tr("ui.alerts.encircled"),
		players[0].global_position + Vector2(0, -90),
		Color("#E74C3C"), 20
	)

func _pick_swarm_scene() -> PackedScene:
	var options = [enemy_scene, fast_enemy_scene, dasher_scene]
	return options[randi() % options.size()]
