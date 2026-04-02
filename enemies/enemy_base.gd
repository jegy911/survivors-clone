class_name EnemyBase
extends Area2D

# Temel istatistikler
var BASE_SPEED = 50.0
var DAMAGE = 10
var XP_VALUE = 5
var XP_DROP_CHANCE = 0.35
var gold_value = 1
var elite_gold_value = 2
var death_scale = 1.4
var particle_color = Color("#E74C3C")
var damage_color = Color.WHITE

# Durum
var player: Node2D = null
var damage_cooldown = 0.0
var hp = 30
var max_hp = 30
var is_dead = false
var current_speed = BASE_SPEED
var slow_timer = 0.0
var rage_triggered = false
var is_swarm_enemy: bool = false
var swarm_direction: Vector2 = Vector2.ZERO
var swarm_speed_override: float = 180.0
var _poison_damage = 0
var _poison_timer = 0.0
var _poison_tick_interval = 1.0


@onready var body = $ColorRect

func _ready():
	add_to_group("enemies")
	_setup_hp_bar()
	_setup_visuals()

func _setup_hp_bar():
	var hp_setting = SaveManager.settings.get("hp_bars", "both_on")
	if hp_setting == "both_off" or hp_setting == "player_only":
		return
	var body_size = body.size if body else Vector2(32, 32)
	var bar_x = -body_size.x / 2
	var bar_y = -body_size.y / 2 - 8
	var bar_width = body_size.x
	var bar_bg = ColorRect.new()
	bar_bg.name = "HPBarBG"
	bar_bg.size = Vector2(bar_width, 4)
	bar_bg.position = Vector2(bar_x, bar_y)
	bar_bg.color = Color("#333333")
	add_child(bar_bg)
	var bar_fill = ColorRect.new()
	bar_fill.name = "HPBarFill"
	bar_fill.size = Vector2(bar_width, 4)
	bar_fill.position = Vector2(bar_x, bar_y)
	bar_fill.color = Color("#E74C3C")
	add_child(bar_fill)

func _update_hp_bar():
	var fill = get_node_or_null("HPBarFill")
	if fill:
		var full_width = body.size.x if body else 32.0
		fill.size.x = full_width * (float(hp) / float(max_hp))

func take_damage(amount: int, shooter: Node = null):
	if shooter != null:
		set_meta("killer", shooter)
	if is_dead:
		return
	# Bağışıklık kontrolü
	var immunity = get_meta("immunity", "")
	if immunity != "":
		amount = int(amount * 0.5)
		player = _get_nearest_player()
	hp -= amount
	# Öfke modu — HP %30'a düşünce
	var main = get_tree().get_first_node_in_group("main")
	if not rage_triggered and float(hp) / float(max_hp) <= 0.30 and main and main.game_timer >= 900:
		rage_triggered = true
		BASE_SPEED *= 1.5
		current_speed = BASE_SPEED
		damage_color = Color("#FF6600")
		if body:
			var rage_tween = body.create_tween()
			rage_tween.set_loops(3)
			rage_tween.tween_property(body, "modulate:a", 0.3, 0.1)
			rage_tween.tween_property(body, "modulate:a", 1.0, 0.1)
	_update_hp_bar()
	
	var dmg_setting = SaveManager.settings.get("damage_numbers", "both_on")
	if dmg_setting == "both_on" or dmg_setting == "enemy_only":
		var popup = ObjectPool.get_object("res://effects/damage_number.tscn")
		popup.global_position = global_position + Vector2(0, -50)
		popup.show_damage(amount, damage_color)
	
	AudioManager.play_hit()
	flash()
	if hp <= 0:
		die()
	# Vuruş geri tepme efekti
	if player != null:
		var knockback_dir = (global_position - player.global_position).normalized()
		global_position += knockback_dir * 4.0

func take_explosion_damage(amount: int):
	if is_dead:
		return
	hp -= amount
	if hp <= 0:
		call_deferred("die")

func apply_slow(factor: float, duration: float):
	current_speed = BASE_SPEED * factor
	slow_timer = duration
	if body:
		body.color = Color("#3498DB")

func apply_poison(damage_per_tick: int, duration: float):
	_poison_damage = damage_per_tick
	_poison_timer = duration
	_poison_tick_interval = 1.0

func flash():
	var sprite = get_node_or_null("AnimatedSprite2D")
	if sprite:
		var tween = sprite.create_tween()
		tween.tween_property(sprite, "modulate", Color(1.5, 1.5, 1.5, 1.0), 0.04)
		tween.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.08)
	elif body:
		var tween = body.create_tween()
		tween.tween_property(body, "color", Color.WHITE, 0.04)
		tween.tween_property(body, "color", _get_original_color(), 0.08)

func _get_original_color() -> Color:
	return body.color if body else Color.WHITE

func die(killer: Node = null):
	if is_dead:
		return
	is_dead = true
	# EventBus.enemy_killed sadece player.on_enemy_killed içinde emit edilir
	AudioManager.play_death()
# Ateş sinerjisi — evrimi olan silahlar varsa %10 patlama
	var player_node = get_tree().get_first_node_in_group("player")
	if player_node:
		var evolved = ["holy_bullet", "toxic_chain", "death_laser", "blood_boomerang", "storm"]
		var evolved_count = 0
		for e in evolved:
			if player_node.active_weapons.has(e):
				evolved_count += 1
		if evolved_count >= 2 and randf() < 0.10:
			var explosion_range = 100.0
			var enemies = get_tree().get_nodes_in_group("enemies")
			for enemy in enemies:
				if enemy == self:
					continue
				if enemy.global_position.distance_to(global_position) < explosion_range:
					enemy.take_damage(int(player_node.get_total_damage(20)))
			var fire_flash = ColorRect.new()
			fire_flash.size = Vector2(200, 200)
			fire_flash.color = Color("#FF4500")
			fire_flash.modulate.a = 0.5
			fire_flash.position = global_position - Vector2(100, 100)
			get_parent().add_child(fire_flash)
			var fire_tween = fire_flash.create_tween()
			fire_tween.tween_property(fire_flash, "modulate:a", 0.0, 0.3)
			fire_tween.tween_callback(fire_flash.queue_free)
	if SaveManager.settings.get("show_vfx", true):
		_spawn_particles()
	_try_drop_gold()
	_try_drop_chest()
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(death_scale, death_scale), 0.08)
	tween.tween_property(self, "scale", Vector2(0.0, 0.0), 0.12)
	tween.tween_callback(_on_death_complete)

func _try_drop_chest():
	var chest_chance = 0.01
	if get_meta("is_elite", false):
		chest_chance = 0.20
	if randf() > chest_chance:
		return
	var chest = load("res://effects/chest.tscn").instantiate()
	get_parent().add_child(chest)
	chest.init(global_position)

func _try_drop_gold():
	var drop_chance = 0.12
	if get_meta("is_elite", false):
		drop_chance = 1.0
	if randf() > drop_chance:
		return
	var orb = ObjectPool.get_object("res://effects/gold_orb.tscn")
	var v = gold_value
	if get_meta("is_elite", false):
		v = elite_gold_value
	var player_node = get_tree().get_first_node_in_group("player")
	if player_node and player_node.active_items.has("luck_stone"):
		v += player_node.active_items["luck_stone"].gold_bonus
	orb.init(v, global_position)

func _spawn_particles():
	for i in 6:
		var particle = ColorRect.new()
		particle.size = Vector2(6, 6)
		particle.color = particle_color
		particle.position = global_position
		get_parent().add_child(particle)
		var angle = (float(i) / 6.0) * TAU
		var target = global_position + Vector2(cos(angle), sin(angle)) * randf_range(30, 60)
		var tween = particle.create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "position", target, 0.3)
		tween.tween_property(particle, "modulate:a", 0.0, 0.3)
		tween.set_parallel(false)
		tween.tween_callback(particle.queue_free)

func _on_death_complete():
	# Co-op: en yakın oyuncu kill alır
	var killer = null
	if has_meta("killer"):
		killer = get_meta("killer")
	if killer == null:
		killer = _get_nearest_player()
	if killer:
		killer.on_enemy_killed(global_position)
	if randf() < XP_DROP_CHANCE:
		var roll = randf()
		var xp_val = XP_VALUE
		var orb_color = Color("#4A90E2") # mavi
		if roll < 0.02: # %2 kırmızı
			xp_val = XP_VALUE * 8
			orb_color = Color("#E74C3C")
		elif roll < 0.10: # %8 yeşil
			xp_val = XP_VALUE * 3
			orb_color = Color("#2ECC71")
		var orb = ObjectPool.get_object("res://effects/xp_orb.tscn")
		orb.init(xp_val, global_position)
		if orb.get_node_or_null("ColorRect"):
			orb.get_node("ColorRect").color = orb_color
	queue_free()


func _physics_process(delta):
	if _poison_timer > 0:
		_poison_timer -= delta
		_poison_tick_interval -= delta
		if _poison_tick_interval <= 0:
			_poison_tick_interval = 1.0
			if not is_dead:
				take_damage(_poison_damage)

	if is_swarm_enemy and not is_dead:
		global_position += swarm_direction * swarm_speed_override * delta
		_update_enemy_direction()
		var players = get_tree().get_nodes_in_group("player")
		if not players.is_empty():
			var center = Vector2.ZERO
			for p in players:
				center += p.global_position
			center /= players.size()
			if global_position.distance_to(center) > 1400:
				is_dead = true
				queue_free()

func _setup_visuals():
	if body:
		body.name = "Body"
	var sprite = get_node_or_null("AnimatedSprite2D")
	if sprite:
		sprite.play("walk_left")

func _update_animation(is_moving: bool):
	var sprite = get_node_or_null("AnimatedSprite2D")
	if sprite == null:
		return
	if is_moving:
		if sprite.sprite_frames.has_animation("walk_left"):
			sprite.play("walk_left")
	else:
		if sprite.sprite_frames.has_animation("idle_left"):
			sprite.play("idle_left")
		elif sprite.sprite_frames.has_animation("walk_left"):
			sprite.play("walk_left")

func _update_enemy_direction():
	var sprite = get_node_or_null("AnimatedSprite2D")
	if sprite == null or player == null:
		return
	if player.global_position.x > global_position.x:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
		
func _get_nearest_player() -> Node2D:
	var players = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return null
	var nearest = players[0]
	var nearest_dist = global_position.distance_to(nearest.global_position)
	for p in players:
		var dist = global_position.distance_to(p.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = p
	return nearest

func make_swarm_enemy(direction: Vector2, speed: float = 180.0):
	is_swarm_enemy = true
	swarm_direction = direction.normalized()
	swarm_speed_override = speed
	set_process(false)
