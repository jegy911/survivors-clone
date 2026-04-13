class_name ItemBloodPool
extends PassiveItem

var pool_damage = 8
var pool_radius = 60.0
var pool_duration = 3.0
var trigger_chance = 0.40
var damage_number_scene = preload("res://effects/damage_number.tscn")

func _ready():
	item_name = "Kan Havuzu"
	description = "Öldürünce alan hasarı bırakır"
	category = "vampire"
	max_level = 5
	super._ready()

func apply():
	pool_damage = 5 + (level - 1) * 3
	pool_radius = 50.0 + (level - 1) * 10.0
	pool_duration = 3.0 + (level - 1) * 0.5
	trigger_chance = 0.15 + (level - 1) * 0.05

func on_enemy_killed(position: Vector2):
	if randf() < trigger_chance:
		_spawn_pool(position)

func _spawn_pool(pos: Vector2):
	var effective_radius = pool_radius * player.get_area_multiplier()
	var effective_duration = pool_duration * player.get_duration_multiplier()
	
	var vfx_a = player.get_player_vfx_opacity() if player else 1.0
	var pool = ColorRect.new()
	pool.size = Vector2(effective_radius * 2, effective_radius * 2)
	pool.position = pos - Vector2(effective_radius, effective_radius)
	pool.color = Color(0.5, 0.0, 0.0, 0.4 * vfx_a)
	player.get_parent().add_child(pool)
	
	var tween = pool.create_tween()
	tween.tween_property(pool, "modulate:a", 0.0, effective_duration)
	tween.tween_callback(pool.queue_free)
	
	var damage_timer = Timer.new()
	damage_timer.wait_time = 0.5
	damage_timer.autostart = true
	pool.add_child(damage_timer)
	
	var dmg = pool_damage
	var radius = effective_radius
	damage_timer.timeout.connect(func():
		if not is_instance_valid(pool):
			return
		var enemies = EnemyRegistry.get_enemies()
		for enemy in enemies:
			if enemy.global_position.distance_to(pos) <= radius:
				if enemy.has_method("take_explosion_damage"):
					enemy.take_explosion_damage(dmg)
	)

func get_description() -> String:
	return "Kan Havuzu Lv" + str(level) + "\nÖlünce " + str(int(pool_radius * player.get_area_multiplier())) + " alanda " + str(pool_damage) + " hasar"
