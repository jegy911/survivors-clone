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

const MAX_ENEMIES = 150
const ELITE_CHANCE = 0.15

var main_node: Node = null

func initialize(main: Node):
	main_node = main

func get_spawn_outside_screen() -> Vector2:
	var players = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return Vector2.ZERO
	# Co-op: tüm oyuncuların ortasından spawn
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

func spawn_random_enemy(game_timer: float, current_immunity: String):
	var enemy = _pick_enemy_for_time(game_timer)
	if enemy == null:
		return
	main_node.add_child(enemy)
	enemy.global_position = get_spawn_outside_screen()
	_apply_scaling(enemy, game_timer)
	_apply_curse(enemy)
	_make_elite(enemy, game_timer)
	if current_immunity != "" and randf() < 0.30:
		_apply_immunity(enemy, current_immunity)

func spawn_mini_boss(game_timer: float, boss_index: int):
	EventBus.boss_spawned.emit()
	var boss = boss_scene.instantiate()
	main_node.add_child(boss)
	boss.global_position = get_spawn_outside_screen()
	if boss.get("hp") != null:
		boss.hp = int(boss.hp * (1.0 + boss_index * 0.3))
		boss.max_hp = boss.hp
	if boss.get("DAMAGE") != null:
		boss.DAMAGE = int(boss.DAMAGE * (1.0 + boss_index * 0.2))

func spawn_reaper(reaper_count: int) -> Node:
	var reaper = boss_scene.instantiate()
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
	return reaper

func _pick_enemy_for_time(t: float) -> Node:
	var roll = randf()
	if t < 60:
		var e = enemy_scene.instantiate()
		e.set_meta("weak_mode", true)
		return e
	if t < 120:
		return enemy_scene.instantiate()
	if t < 180:
		if roll < 0.75:
			return enemy_scene.instantiate()
		else:
			return fast_enemy_scene.instantiate()
	if roll < 0.20:
		return enemy_scene.instantiate() if randf() > 0.5 else fast_enemy_scene.instantiate()
	var r = randf()
	if t < 300:
		if r < 0.6: return fast_enemy_scene.instantiate()
		else: return dasher_scene.instantiate()
	elif t < 420:
		if r < 0.35: return fast_enemy_scene.instantiate()
		elif r < 0.65: return dasher_scene.instantiate()
		else: return tank_enemy_scene.instantiate()
	elif t < 540:
		if r < 0.30: return dasher_scene.instantiate()
		elif r < 0.60: return tank_enemy_scene.instantiate()
		else: return healer_scene.instantiate()
	elif t < 660:
		if r < 0.25: return exploder_scene.instantiate()
		elif r < 0.50: return tank_enemy_scene.instantiate()
		elif r < 0.75: return dasher_scene.instantiate()
		else: return healer_scene.instantiate()
	elif t < 900:
		if r < 0.25: return exploder_scene.instantiate()
		elif r < 0.40: return dasher_scene.instantiate()
		elif r < 0.55: return shield_enemy_scene.instantiate()
		elif r < 0.70: return tank_enemy_scene.instantiate()
		elif r < 0.85: return healer_scene.instantiate()
		else: return fast_enemy_scene.instantiate()
	elif t < 1200:
		if r < 0.20: return giant_scene.instantiate()
		elif r < 0.40: return shield_enemy_scene.instantiate()
		elif r < 0.60: return healer_scene.instantiate()
		elif r < 0.80: return exploder_scene.instantiate()
		else: return tank_enemy_scene.instantiate()
	else:
		match randi() % 5:
			0: return giant_scene.instantiate()
			1: return shield_enemy_scene.instantiate()
			2: return exploder_scene.instantiate()
			3: return healer_scene.instantiate()
			_: return tank_enemy_scene.instantiate()

func _apply_scaling(enemy: Node, game_timer: float):
	var minutes = game_timer / 60.0
	var hp_mult = 1.0 + minutes * 0.04
	var dmg_mult = 1.0 + minutes * 0.04
	var spd_mult = 1.0 + minutes * 0.02
	if enemy.get("hp") != null:
		enemy.hp = int(enemy.hp * hp_mult)
		enemy.max_hp = enemy.hp
	if enemy.get("DAMAGE") != null:
		enemy.DAMAGE = int(enemy.DAMAGE * dmg_mult)
	if enemy.get("SPEED") != null:
		enemy.SPEED *= spd_mult
	if enemy.get("BASE_SPEED") != null:
		enemy.BASE_SPEED *= spd_mult

func _apply_curse(enemy: Node):
	var curse = SaveManager.meta_upgrades.get("curse_level", 0)
	if curse <= 0:
		return
	var speed_mult = 1.0 + curse * 0.10
	if enemy.get("SPEED") != null:
		enemy.SPEED *= speed_mult
	if enemy.get("BASE_SPEED") != null:
		enemy.BASE_SPEED *= speed_mult

func _make_elite(enemy: Node, game_timer: float):
	if game_timer < 60:
		return
	if randf() > ELITE_CHANCE:
		return
	if enemy.get("hp") != null:
		enemy.hp = int(enemy.hp * 2.0)
		enemy.max_hp = enemy.hp
	if enemy.get("DAMAGE") != null:
		enemy.DAMAGE = int(enemy.DAMAGE * 1.5)
	if enemy.get("SPEED") != null:
		enemy.SPEED *= 1.2
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

func _apply_immunity(enemy: Node, immunity_type: String):
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

func apply_immunity_to_existing(current_immunity: String):
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if randf() < 0.30:
			_apply_immunity(enemy, current_immunity)
