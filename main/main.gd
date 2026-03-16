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
var spawn_interval = 3.0
var enemies_per_wave = 2
var wave_timer = 0.0
var wave_interval = 60.0
var wave_count = 0
var reward_active = false
var vacuum_spawn_timer = 120.0
var trap_spawn_timer = 30.0
var shrine_spawn_timer = 90.0
var crate_spawn_timer = 45.0
var reaper_mode = false
var reaper_count = 0
var siege_timer = 0.0
var siege_active = false
var siege_cooldown_timer = 0.0
const SIEGE_DURATION = 120.0
const SIEGE_COOLDOWN = 60.0
var game_timer = 0.0

# Boss takibi
var mini_boss_times = [300, 600, 900, 1200, 1500]
var next_mini_boss_index = 0
var final_boss_spawned = false

const MAX_ENEMIES = 150
const ELITE_CHANCE = 0.15
const GOLD_DROP_CHANCE = 0.12

var hit_stop_frames = 0

@onready var timer_label = $HUD/TimerLabel
@onready var wave_label = $HUD/WaveLabel

func _ready():
	randomize()
	add_to_group("main")
	EventBus.game_started.emit()
	EventBus.hit_stop_requested.connect(_on_hit_stop_requested)

func _on_hit_stop_requested(frames: int):
	hit_stop_frames = max(hit_stop_frames, frames)

func get_curse_level() -> int:
	return SaveManager.meta_upgrades.get("curse_level", 0)

func get_effective_spawn_interval() -> float:
	var curse = get_curse_level()
	return max(0.2, spawn_interval * (1.0 - curse * 0.10))

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

	# 30. dakikada Reaper modu
	if game_timer >= 1800 and not reaper_mode:
		_start_reaper_mode()
	
	# Reaper modunda sürekli spawn
	if reaper_mode:
		spawn_timer -= delta
		if spawn_timer <= 0:
			spawn_timer = 8.0
			_spawn_reaper()
		return
	
	# 15. dakikadan sonra siege sistemi (sadece 15-30 dk arası)
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

	# Her dakika spawn artışı
	wave_timer += delta
	if wave_timer >= wave_interval:
		wave_timer = 0.0
		wave_count += 1
		enemies_per_wave += 2
		spawn_interval = max(0.2, spawn_interval - 0.08)
		_show_wave_reward()

	# Spawn (reaper modunda yukarıda return edildi)
	spawn_timer -= delta
	if spawn_timer <= 0:
		var current_count = get_tree().get_nodes_in_group("enemies").size()
		if current_count < MAX_ENEMIES:
			var to_spawn = get_effective_enemies_per_wave()
			if siege_active:
				to_spawn = get_effective_enemies_per_wave() * 3
			var can_spawn = min(to_spawn, MAX_ENEMIES - current_count)
			for i in can_spawn:
				spawn_random_enemy()
		spawn_timer = get_effective_spawn_interval() * (0.3 if siege_active else 1.0)
	
	# Vacuum orb spawn
	vacuum_spawn_timer -= delta
	if vacuum_spawn_timer <= 0:
		vacuum_spawn_timer = randf_range(90.0, 150.0)
		_spawn_vacuum_orb()

	# Tuzak spawn
	trap_spawn_timer -= delta
	if trap_spawn_timer <= 0:
		trap_spawn_timer = randf_range(20.0, 40.0)
		_spawn_trap()
	
	# Sunak spawn
	shrine_spawn_timer -= delta
	if shrine_spawn_timer <= 0:
		shrine_spawn_timer = randf_range(60.0, 120.0)
		_spawn_shrine()
	
	# Sandık spawn
	crate_spawn_timer -= delta
	if crate_spawn_timer <= 0:
		crate_spawn_timer = randf_range(30.0, 60.0)
		_spawn_crate()

func update_timer_label():
	if game_timer <= 1800.0:
		var remaining = 1800.0 - game_timer
		var minutes = int(remaining) / 60
		var seconds = int(remaining) % 60
		timer_label.text = "%02d:%02d" % [minutes, seconds]
		timer_label.add_theme_color_override("font_color", Color("#FFFFFF"))
		timer_label.add_theme_font_size_override("font_size", 18)
	else:
		var over = game_timer - 1800.0
		var minutes = int(over) / 60
		var seconds = int(over) % 60
		timer_label.text = "%02d:%02d" % [minutes, seconds]
		timer_label.add_theme_color_override("font_color", Color("#8B0000"))
		timer_label.add_theme_font_size_override("font_size", 24)
	wave_label.text = "Dalga: " + str(wave_count)

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

	# 0-1 dakika: sadece weak mode
	if t < 60:
		var e = enemy_scene.instantiate()
		e.set_meta("weak_mode", true)
		return e

	# 1-2 dakika: sadece normal basic
	if t < 120:
		return enemy_scene.instantiate()

	# 2-3 dakika: basic dominant, az fast
	if t < 180:
		if roll < 0.75:
			return enemy_scene.instantiate()
		else:
			return fast_enemy_scene.instantiate()

	# 3+ dakika: her zaman %20 level-1 karışımı
	if roll < 0.20:
		return enemy_scene.instantiate() if randf() > 0.5 else fast_enemy_scene.instantiate()

	var r = randf()

	# 3:00 - 5:00
	if t < 300:
		if r < 0.6: return fast_enemy_scene.instantiate()
		else: return dasher_scene.instantiate()
	# 5:00 - 7:00
	elif t < 420:
		if r < 0.35: return fast_enemy_scene.instantiate()
		elif r < 0.65: return dasher_scene.instantiate()
		else: return tank_enemy_scene.instantiate()
	# 7:00 - 9:00 (hâlâ exploder yok)
	elif t < 540:
		if r < 0.30: return dasher_scene.instantiate()
		elif r < 0.60: return tank_enemy_scene.instantiate()
		else: return healer_scene.instantiate()
	# 9:00 - 11:00 → exploder giriyor
	elif t < 660:
		if r < 0.25: return exploder_scene.instantiate()
		elif r < 0.50: return tank_enemy_scene.instantiate()
		elif r < 0.75: return dasher_scene.instantiate()
		else: return healer_scene.instantiate()
	# 11:00 - 15:00
	elif t < 900:
		if r < 0.20: return exploder_scene.instantiate()
		elif r < 0.40: return tank_enemy_scene.instantiate()
		elif r < 0.60: return healer_scene.instantiate()
		elif r < 0.80: return shield_enemy_scene.instantiate()
		else: return dasher_scene.instantiate()
	# 15:00 - 20:00
	elif t < 1200:
		if r < 0.20: return giant_scene.instantiate()
		elif r < 0.40: return shield_enemy_scene.instantiate()
		elif r < 0.60: return healer_scene.instantiate()
		elif r < 0.80: return exploder_scene.instantiate()
		else: return tank_enemy_scene.instantiate()
	# 20:00+
	else:
		match randi() % 5:
			0: return giant_scene.instantiate()
			1: return shield_enemy_scene.instantiate()
			2: return exploder_scene.instantiate()
			3: return healer_scene.instantiate()
			_: return tank_enemy_scene.instantiate()


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
				player.gain_xp(player.xp_to_next_level * 2)
			"damage":
				player.bullet_damage += 10
	overlay.queue_free()
	get_tree().paused = false
	reward_active = false

func _spawn_vacuum_orb():
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	
	var orb_node = Node2D.new()
	var body = ColorRect.new()
	body.size = Vector2(20, 20)
	body.position = Vector2(-10, -10)
	body.color = Color("#00FFFF")
	orb_node.add_child(body)
	
	var area = Area2D.new()
	area.collision_layer = 0
	area.collision_mask = 1
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 18.0
	shape.shape = circle
	area.add_child(shape)
	orb_node.add_child(area)
	
	add_child(orb_node)
	
	var angle = randf() * TAU
	orb_node.global_position = player.global_position + Vector2(cos(angle), sin(angle)) * randf_range(100.0, 250.0)
	
	var pulse = body.create_tween()
	pulse.set_loops()
	pulse.tween_property(body, "modulate:a", 0.3, 0.4)
	pulse.tween_property(body, "modulate:a", 1.0, 0.4)
	
	area.body_entered.connect(_on_vacuum_collected.bind(orb_node, area))

func _on_vacuum_collected(body: Node, orb_node: Node, _area: Node):
	if not is_instance_valid(orb_node):
		return
	if not body.is_in_group("player"):
		return
	var xp_orbs = get_tree().get_nodes_in_group("xp_orbs")
	for xo in xp_orbs:
		if xo.has_method("vacuum_attract"):
			xo.vacuum_attract()
	var gold_orbs = get_tree().get_nodes_in_group("gold_orbs")
	for go in gold_orbs:
		if go.has_method("vacuum_attract"):
			go.vacuum_attract()
	body.show_floating_text("🌀 VAKUM!", orb_node.global_position + Vector2(0, -40), Color("#00FFFF"), 20)
	orb_node.queue_free()
	
	await get_tree().create_timer(15.0).timeout
	if is_instance_valid(orb_node):
		var fade = body.create_tween()
		fade.tween_property(body, "modulate:a", 0.0, 1.0)
		fade.tween_callback(orb_node.queue_free)

func _start_reaper_mode():
	reaper_mode = true
	# Tüm normal düşmanları temizle
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not enemy.is_in_group("boss"):
			enemy.queue_free()
	# Ekrana uyarı
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.show_floating_text("☠ ÖLÜM GELİYOR...", player.global_position + Vector2(0, -100), Color("#8B0000"), 28)
	await get_tree().create_timer(3.0).timeout
	_spawn_reaper()

func _spawn_reaper():
	var reaper = boss_scene.instantiate()
	add_child(reaper)
	reaper.global_position = get_spawn_outside_screen()
	reaper_count += 1
	# Her Reaper öncekinden %50 daha güçlü
	var mult = 1.0 + reaper_count * 0.5
	if reaper.get("hp") != null:
		reaper.hp = int(500 * mult * 3)
		reaper.max_hp = reaper.hp
	if reaper.get("DAMAGE") != null:
		reaper.DAMAGE = int(80 * mult)
	if reaper.get("BASE_SPEED") != null:
		reaper.BASE_SPEED = 90.0 + reaper_count * 5.0
		reaper.current_speed = reaper.BASE_SPEED
	# Kırmızı-siyah renk
	if reaper.get_node_or_null("ColorRect"):
		reaper.get_node("ColorRect").color = Color("#1A0000")
	# Ölünce yenisi gelsin
	reaper.tree_exited.connect(_on_reaper_died)
	# Label
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.show_floating_text("☠ REAPER #" + str(reaper_count), reaper.global_position + Vector2(0, -60), Color("#8B0000"), 20)

func _start_siege_wave():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.show_floating_text("⚠ KUŞATMA!", player.global_position + Vector2(0, -80), Color("#FF6600"), 22)

func _on_reaper_died():
	if not reaper_mode:
		return
	await get_tree().create_timer(2.0).timeout
	if reaper_mode:
		_spawn_reaper()

func _spawn_trap():
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	var trap
	if randf() > 0.5:
		trap = load("res://effects/freeze_barrel.gd").new()
	else:
		trap = load("res://effects/poison_trap.gd").new()
	add_child(trap)
	var angle = randf() * TAU
	trap.global_position = player.global_position + Vector2(cos(angle), sin(angle)) * randf_range(150.0, 350.0)
	# 30 sn sonra yok ol
	await get_tree().create_timer(30.0).timeout
	if is_instance_valid(trap):
		trap.queue_free()

func _spawn_shrine():
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	var shrine = load("res://effects/shrine_of_risk.gd").new()
	add_child(shrine)
	var angle = randf() * TAU
	shrine.global_position = player.global_position + Vector2(cos(angle), sin(angle)) * randf_range(200.0, 400.0)
	await get_tree().create_timer(45.0).timeout
	if is_instance_valid(shrine):
		shrine.queue_free()

func _spawn_crate():
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	var crate = load("res://effects/destructible_crate.gd").new()
	add_child(crate)
	var angle = randf() * TAU
	crate.global_position = player.global_position + Vector2(cos(angle), sin(angle)) * randf_range(100.0, 300.0)
