extends EnemyBase

const EXPLOSION_RADIUS = 120.0
var is_exploding = false

func _ready():
	super._ready()
	BASE_SPEED = 65.0
	DAMAGE = 50
	XP_VALUE = 10
	XP_DROP_CHANCE = 0.75
	gold_value = 2
	elite_gold_value = 5
	current_speed = BASE_SPEED
	particle_color = Color("#FF6B00")
	body.color = Color("#FF6B00")

func _process(delta):
	if is_dead or player == null:
		return
	var dist = global_position.distance_to(player.global_position)
	if dist < 60 and not is_exploding:
		explode()
		return
	var direction = (player.global_position - global_position).normalized()
	global_position += direction * BASE_SPEED * delta

func explode():
	is_exploding = true
	is_dead = true
	_try_drop_gold()
	var enemies_and_player = get_tree().get_nodes_in_group("player")
	for p in enemies_and_player:
		if p.global_position.distance_to(global_position) < EXPLOSION_RADIUS:
			p.take_damage(DAMAGE)
	if SaveManager.settings.get("show_vfx", true):
		for i in 12:
			var particle = ColorRect.new()
			particle.size = Vector2(10, 10)
			particle.color = Color("#FF6B00")
			particle.position = global_position
			get_parent().add_child(particle)
			var angle = (float(i) / 12.0) * TAU
			var target = global_position + Vector2(cos(angle), sin(angle)) * randf_range(60, 120)
			var tween = particle.create_tween()
			tween.set_parallel(true)
			tween.tween_property(particle, "position", target, 0.4)
			tween.tween_property(particle, "modulate:a", 0.0, 0.4)
			tween.set_parallel(false)
			tween.tween_callback(particle.queue_free)
	_on_death_complete()

func take_damage(amount: int):
	if is_dead:
		return
	if SaveManager.settings.get("show_damage_numbers", true):
		var popup = ObjectPool.get_object("res://effects/damage_number.tscn")
		popup.global_position = global_position + Vector2(0, -50)
		popup.show_damage(amount, Color.WHITE)
	AudioManager.play_hit()
	explode()

func take_explosion_damage(amount: int):
	if is_dead:
		return
	explode()

func apply_poison(_damage_per_tick: int, _duration: float):
	if is_dead:
		return
	explode()

func flash():
	pass
