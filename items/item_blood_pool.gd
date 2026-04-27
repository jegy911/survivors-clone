class_name ItemBloodPool
extends PassiveItem

const POOL_TEX := preload("res://assets/effects/blood_pool_ripple.png")

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
	var pool := Sprite2D.new()
	pool.texture = POOL_TEX
	pool.centered = true
	pool.global_position = pos
	pool.z_index = -2
	var dim: float = maxf(float(POOL_TEX.get_width()), 1.0)
	var sc: float = (effective_radius * 2.0) / dim
	pool.scale = Vector2(sc, sc)
	pool.modulate = Color(1.0, 1.0, 1.0, 0.72 * vfx_a)
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
	var center_pos: Vector2 = pos
	damage_timer.timeout.connect(func():
		if not is_instance_valid(pool):
			return
		var enemies = EnemyRegistry.get_enemies()
		for enemy in enemies:
			if enemy.global_position.distance_to(center_pos) <= radius:
				if enemy.has_method("take_explosion_damage"):
					enemy.take_explosion_damage(dmg)
	)

func get_description() -> String:
	return tr("ui.upgrade_ui.stats.loadout_items.blood_pool") % [
		level,
		int(pool_radius * player.get_area_multiplier()),
		pool_damage,
	]
