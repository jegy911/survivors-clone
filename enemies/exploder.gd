extends EnemyBase

const EXPLOSION_RADIUS = 120.0
const _WARN_DISTANCE = 95.0
var is_exploding = false
var _warn_pulse_t := 0.0

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
	player = _get_nearest_player()
	if is_dead or player == null:
		return
	var dist = global_position.distance_to(player.global_position)
	if dist < 60 and not is_exploding:
		explode()
		return
	var spr = get_node_or_null("AnimatedSprite2D")
	if spr and dist < _WARN_DISTANCE:
		_warn_pulse_t += delta * 10.0
		var w = 0.55 + 0.45 * sin(_warn_pulse_t)
		spr.modulate = Color(1.0, 0.2 + 0.75 * w, 0.12, 1.0)
	elif spr:
		spr.modulate = Color.WHITE
	var direction = (player.global_position - global_position).normalized()
	global_position += direction * BASE_SPEED * delta

	_update_enemy_direction()

func explode():
	var spr_done = get_node_or_null("AnimatedSprite2D")
	if spr_done:
		spr_done.modulate = Color.WHITE
	is_exploding = true
	is_dead = true
	_notify_enemy_kill_to_player(null)
	var enemies_and_player = get_tree().get_nodes_in_group("player")
	for p in enemies_and_player:
		if p.global_position.distance_to(global_position) < EXPLOSION_RADIUS:
			p.take_damage(DAMAGE, self)
	if SaveManager.is_heavy_vfx_enabled():
		var pc := SaveManager.get_particle_burst_count(12)
		for i in pc:
			var particle = ColorRect.new()
			particle.size = Vector2(10, 10)
			particle.color = Color("#FF6B00")
			particle.position = global_position
			get_parent().add_child(particle)
			var angle = (float(i) / float(pc)) * TAU
			var target = global_position + Vector2(cos(angle), sin(angle)) * randf_range(60, 120)
			var tween = particle.create_tween()
			tween.set_parallel(true)
			tween.tween_property(particle, "position", target, 0.4)
			tween.tween_property(particle, "modulate:a", 0.0, 0.4)
			tween.set_parallel(false)
			tween.tween_callback(particle.queue_free)
	_on_death_complete()

func take_damage(amount: int, shooter: Node = null):
	if is_dead:
		return
	if shooter != null:
		set_meta("killer", shooter)
	if SaveManager.settings.get("show_damage_numbers", true):
		var popup = ObjectPool.get_object("res://effects/damage_number.tscn")
		popup.global_position = global_position + Vector2(0, -50)
		popup.show_damage(amount, Color.WHITE)
	AudioManager.play_hit()
	explode()

func take_explosion_damage(_amount: int):
	if is_dead:
		return
	explode()

func apply_poison(_damage_per_tick: int, _duration: float):
	if is_dead:
		return
	explode()
