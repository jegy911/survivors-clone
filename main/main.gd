extends Node2D

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

var spawn_timer = 0.0
var spawn_interval = 3.5
var enemies_per_wave = 3
var wave_timer = 0.0
var wave_interval = 60.0
var wave_count = 0
var reward_active = false
var game_timer = 0.0

# Boss takibi
var mini_boss_times = [180, 360, 600, 900, 1140, 1380, 1620]  # saniye cinsinden
var next_mini_boss_index = 0
var final_boss_spawned = false

const MAX_ENEMIES = 80
const ELITE_CHANCE = 0.15
const GOLD_DROP_CHANCE = 0.12

var hit_stop_frames = 0

@onready var timer_label = $HUD/TimerLabel
@onready var wave_label = $HUD/WaveLabel

func _ready():
	randomize()
	add_to_group("main")
	var ground = ColorRect.new()
	ground.color = Color("#2D5A1B")
	ground.size = Vector2(99999, 99999)
	ground.position = Vector2(-50000, -50000)
	ground.z_index = -10
	add_child(ground)
	move_child(ground, 0)
	EventBus.game_started.emit()
	EventBus.hit_stop_requested.connect(_on_hit_stop_requested)

func _on_hit_stop_requested(frames: int):
	hit_stop_frames = max(hit_stop_frames, frames)

func get_curse_level() -> int:
	return SaveManager.meta_upgrades.get("curse_level", 0)

func get_effective_spawn_interval() -> float:
	var curse = get_curse_level()
	return max(0.8, spawn_interval * (1.0 - curse * 0.10))

func get_effective_enemies_per_wave() -> int:
	return enemies_per_wave + get_curse_level()

func get_enemy_hp_multiplier() -> float:
	var minutes = game_timer / 60.0
	return 1.0 + minutes * 0.08

func get_enemy_damage_multiplier() -> float:
	var minutes = game_timer / 60.0
	return 1.0 + minutes * 0.04

func get_enemy_speed_multiplier() -> float:
	var minutes = game_timer / 60.0
	return 1.0 + minutes * 0.02

func _process(delta):
	if hit_stop_frames > 0:
		Engine.time_scale = 0.0
		hit_stop_frames -= 1
		return
	else:
		Engine.time_scale = 1.0
	
	game_timer += delta
	update_timer_label()
	
	if game_timer >= 900 and AudioManager.current_music == 1:
		AudioManager.play_music(2)

	# Mini boss kontrolü
	if next_mini_boss_index < mini_boss_times.size():
		if game_timer >= mini_boss_times[next_mini_boss_index]:
			spawn_mini_boss()
			next_mini_boss_index += 1

	# Final boss 30. dakikada
	if game_timer >= 1800 and not final_boss_spawned:
		spawn_final_boss()
		final_boss_spawned = true

	# Her dakika spawn artışı
	wave_timer += delta
	if wave_timer >= wave_interval:
		wave_timer = 0.0
		wave_count += 1
		enemies_per_wave += 1
		spawn_interval = max(0.8, spawn_interval - 0.15)
		_show_wave_reward()

	# Spawn
	spawn_timer -= delta
	if spawn_timer <= 0:
		var current_count = get_tree().get_nodes_in_group("enemies").size()
		if current_count < MAX_ENEMIES:
			var to_spawn = min(get_effective_enemies_per_wave(), MAX_ENEMIES - current_count)
			for i in to_spawn:
				spawn_random_enemy()
		spawn_timer = get_effective_spawn_interval()

func update_timer_label():
	var minutes = int(game_timer) / 60
	var seconds = int(game_timer) % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]
	wave_label.text = "Dalga: " + str(enemies_per_wave)

func _apply_scaling(enemy: Node):
	var hp_mult = get_enemy_hp_multiplier()
	var dmg_mult = get_enemy_damage_multiplier()
	var spd_mult = get_enemy_speed_multiplier()
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
	var curse = get_curse_level()
	if curse <= 0:
		return
	var speed_mult = 1.0 + curse * 0.10
	if enemy.get("SPEED") != null:
		enemy.SPEED *= speed_mult
	if enemy.get("BASE_SPEED") != null:
		enemy.BASE_SPEED *= speed_mult

func _make_elite(enemy: Node):
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

func spawn_random_enemy():
	var enemy = _pick_enemy_for_time()
	if enemy == null:
		return
	add_child(enemy)
	enemy.global_position = get_spawn_outside_screen()
	_apply_scaling(enemy)
	_apply_curse(enemy)
	_make_elite(enemy)

func _pick_enemy_for_time() -> Node:
	var t = game_timer
	var roll = randf()

	# 0:00 - 1:00 → sadece zayıf temel
	if t < 60:
		var e = enemy_scene.instantiate()
		e.set_meta("weak_mode", true)
		return e

	# 1:00 - 2:00 → temel + ilk fast enemy girişi
	elif t < 120:
		if roll < 0.7:
			var e = enemy_scene.instantiate()
			if roll < 0.3:
				e.set_meta("weak_mode", true)
			return e
		else:
			return fast_enemy_scene.instantiate()

	# 2:00 - 3:00 → fast dominant + exploder girişi
	elif t < 180:
		if roll < 0.15:
			return enemy_scene.instantiate()
		elif roll < 0.65:
			return fast_enemy_scene.instantiate()
		else:
			return exploder_scene.instantiate()

	# 3:00 - 4:00 → fast + exploder + dasher girişi
	elif t < 240:
		if roll < 0.10:
			return enemy_scene.instantiate()
		elif roll < 0.40:
			return fast_enemy_scene.instantiate()
		elif roll < 0.65:
			return exploder_scene.instantiate()
		else:
			return dasher_scene.instantiate()

	# 4:00 - 6:00 → dasher dominant + tank girişi
	elif t < 360:
		if roll < 0.10:
			return fast_enemy_scene.instantiate()
		elif roll < 0.20:
			return exploder_scene.instantiate()
		elif roll < 0.60:
			return dasher_scene.instantiate()
		else:
			return tank_enemy_scene.instantiate()

	# 6:00 - 8:00 → tank + fast + ranged girişi
	elif t < 480:
		if roll < 0.15:
			return fast_enemy_scene.instantiate()
		elif roll < 0.40:
			return tank_enemy_scene.instantiate()
		elif roll < 0.65:
			return dasher_scene.instantiate()
		else:
			return ranged_enemy_scene.instantiate()

	# 8:00 - 10:00 → ranged dominant + healer girişi
	elif t < 600:
		if roll < 0.10:
			return tank_enemy_scene.instantiate()
		elif roll < 0.20:
			return dasher_scene.instantiate()
		elif roll < 0.60:
			return ranged_enemy_scene.instantiate()
		else:
			return healer_scene.instantiate()

	# 10:00 - 13:00 → healer + tank + shield girişi
	elif t < 780:
		if roll < 0.15:
			return ranged_enemy_scene.instantiate()
		elif roll < 0.35:
			return tank_enemy_scene.instantiate()
		elif roll < 0.60:
			return healer_scene.instantiate()
		else:
			return shield_enemy_scene.instantiate()

	# 13:00 - 16:00 → shield + ranged + giant girişi
	elif t < 960:
		if roll < 0.10:
			return tank_enemy_scene.instantiate()
		elif roll < 0.25:
			return healer_scene.instantiate()
		elif roll < 0.55:
			return shield_enemy_scene.instantiate()
		elif roll < 0.80:
			return ranged_enemy_scene.instantiate()
		else:
			return giant_scene.instantiate()

	# 16:00 - 20:00 → giant + dasher ağır karışım
	elif t < 1200:
		if roll < 0.15:
			return shield_enemy_scene.instantiate()
		elif roll < 0.30:
			return healer_scene.instantiate()
		elif roll < 0.50:
			return giant_scene.instantiate()
		elif roll < 0.70:
			return dasher_scene.instantiate()
		else:
			return ranged_enemy_scene.instantiate()

	# 20:00 - 25:00 → tam kaos karışım
	elif t < 1500:
		match randi() % 7:
			0: return fast_enemy_scene.instantiate()
			1: return tank_enemy_scene.instantiate()
			2: return ranged_enemy_scene.instantiate()
			3: return dasher_scene.instantiate()
			4: return healer_scene.instantiate()
			5: return shield_enemy_scene.instantiate()
			6: return giant_scene.instantiate()

	# 25:00 - 30:00 → elite ağırlıklı tam kaos
	else:
		match randi() % 6:
			0: return tank_enemy_scene.instantiate()
			1: return ranged_enemy_scene.instantiate()
			2: return giant_scene.instantiate()
			3: return shield_enemy_scene.instantiate()
			4: return healer_scene.instantiate()
			5: return dasher_scene.instantiate()

	return enemy_scene.instantiate()

func spawn_mini_boss():
	EventBus.boss_spawned.emit()
	var boss = boss_scene.instantiate()
	add_child(boss)
	boss.global_position = get_spawn_outside_screen()
	# Mini boss güçlendirme
	if boss.get("hp") != null:
		boss.hp = int(boss.hp * (1.0 + next_mini_boss_index * 0.3))
		boss.max_hp = boss.hp
	if boss.get("DAMAGE") != null:
		boss.DAMAGE = int(boss.DAMAGE * (1.0 + next_mini_boss_index * 0.2))

func spawn_final_boss():
	EventBus.boss_spawned.emit()
	var boss = boss_scene.instantiate()
	add_child(boss)
	boss.global_position = get_spawn_outside_screen()
	if boss.get("hp") != null:
		boss.hp = boss.hp * 5
		boss.max_hp = boss.hp
	if boss.get("DAMAGE") != null:
		boss.DAMAGE = int(boss.DAMAGE * 3)
	# Altın border — final boss kırmızı
	var border = ColorRect.new()
	border.color = Color(1.0, 0.2, 0.0, 0.5)
	border.size = Vector2(60, 60)
	border.position = Vector2(-30, -30)
	border.z_index = -1
	boss.add_child(border)
	var tween = border.create_tween()
	tween.set_loops()
	tween.tween_property(border, "modulate:a", 1.0, 0.3)
	tween.tween_property(border, "modulate:a", 0.2, 0.3)

func get_spawn_outside_screen() -> Vector2:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return Vector2.ZERO
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
	return player.global_position + pos

func _show_wave_reward():
	reward_active = true
	get_tree().paused = true
	
	var overlay = CanvasLayer.new()
	overlay.name = "WaveRewardOverlay"
	add_child(overlay)
	
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.75)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.process_mode = Node.PROCESS_MODE_ALWAYS
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
	var player = get_tree().get_first_node_in_group("player")
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
	var player = get_tree().get_first_node_in_group("player")
	if player:
		match choice["type"]:
			"gold":
				player.gold_earned += choice["amount"]
				SaveManager.gold += choice["amount"]
				SaveManager.save_game()
			"heal":
				var heal = int(player.max_hp * 0.25)
				player.hp = min(player.hp + heal, player.max_hp)
				EventBus.player_hp_changed.emit(player.hp, player.max_hp)
			"item":
				var items = ["lifesteal", "armor", "crit", "shield"]
				items.shuffle()
				player.add_item(items[0])
			"xp":
				for i in 2:
					player.level_up()
			"damage":
				player.bullet_damage += 10
	overlay.queue_free()
	get_tree().paused = false
	reward_active = false
