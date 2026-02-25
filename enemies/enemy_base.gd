class_name EnemyBase
extends Area2D

# Temel istatistikler
var BASE_SPEED = 50.0
var DAMAGE = 10
var XP_VALUE = 5
var XP_DROP_CHANCE = 0.65
var gold_value = 1
var elite_gold_value = 3
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


@onready var body = $ColorRect

func _ready():
	player = get_tree().get_first_node_in_group("player")
	add_to_group("enemies")
	_setup_hp_bar()

func _setup_hp_bar():
	if not SaveManager.settings.get("show_hp_bars", true):
		return
	var bar_bg = ColorRect.new()
	bar_bg.name = "HPBarBG"
	bar_bg.size = Vector2(32, 4)
	bar_bg.position = Vector2(-16, -24)
	bar_bg.color = Color("#333333")
	add_child(bar_bg)
	var bar_fill = ColorRect.new()
	bar_fill.name = "HPBarFill"
	bar_fill.size = Vector2(32, 4)
	bar_fill.position = Vector2(-16, -24)
	bar_fill.color = Color("#E74C3C")
	add_child(bar_fill)

func _update_hp_bar():
	var fill = get_node_or_null("HPBarFill")
	if fill:
		fill.size.x = 32.0 * (float(hp) / float(max_hp))

func take_damage(amount: int):
	if is_dead:
		return
	hp -= amount
	_update_hp_bar()
	
	if SaveManager.settings.get("show_damage_numbers", true):
		var popup = ObjectPool.get_object("res://effects/damage_number.tscn")
		popup.global_position = global_position + Vector2(0, -50)
		popup.show_damage(amount, damage_color)
	
	AudioManager.play_hit()
	flash()
	if hp <= 0:
		die()

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
	var ticks = int(duration)
	for i in ticks:
		await get_tree().create_timer(float(i + 1)).timeout
		if is_dead or not is_instance_valid(self):
			return
		take_damage(damage_per_tick)

func flash():
	pass

func die():
	if is_dead:
		return
	is_dead = true
	AudioManager.play_death()
	if SaveManager.settings.get("show_vfx", true):
		_spawn_particles()
	_try_drop_gold()
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(death_scale, death_scale), 0.08)
	tween.tween_property(self, "scale", Vector2(0.0, 0.0), 0.12)
	tween.tween_callback(_on_death_complete)

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
	var player_node = get_tree().get_first_node_in_group("player")
	if player_node:
		player_node.add_kill()
		player_node.on_enemy_killed(global_position)
	if randf() < XP_DROP_CHANCE:
		var orb = ObjectPool.get_object("res://effects/xp_orb.tscn")
		orb.init(XP_VALUE, global_position)
	queue_free()
