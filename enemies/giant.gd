extends EnemyBase

func _ready():
	super._ready()
	BASE_SPEED = 26.0
	DAMAGE = 60
	XP_VALUE = 40
	XP_DROP_CHANCE = 0.95
	hp = 500
	max_hp = 500
	death_scale = 3.5
	current_speed = BASE_SPEED
	particle_color = Color("#8B0000")
	body.color = Color("#8B0000")
	scale = Vector2(2.5, 2.5)

func _process(delta):
	player = _get_nearest_player()
	if is_dead or player == null:
		return
	damage_cooldown -= delta
	var direction = (player.global_position - global_position).normalized()
	global_position += direction * BASE_SPEED * delta
	if damage_cooldown <= 0 and global_position.distance_to(player.global_position) < 70:
		player.take_damage(DAMAGE)
		damage_cooldown = 2.0

	_update_enemy_direction()

func flash():
	var tween = create_tween()
	body.color = Color.WHITE
	tween.tween_property(body, "color", Color("#8B0000"), 0.15)

func die(killer: Node = null):
	if is_dead:
		return
	is_dead = true
	AudioManager.play_death()
	_try_drop_gold()
	if SaveManager.is_heavy_vfx_enabled():
		var gc := SaveManager.get_particle_burst_count(16)
		for i in gc:
			var particle = ColorRect.new()
			particle.size = Vector2(12, 12)
			particle.color = Color("#8B0000")
			particle.position = global_position
			get_parent().add_child(particle)
			var angle = (float(i) / float(gc)) * TAU
			var target = global_position + Vector2(cos(angle), sin(angle)) * randf_range(80, 160)
			var tween = particle.create_tween()
			tween.set_parallel(true)
			tween.tween_property(particle, "position", target, 0.5)
			tween.tween_property(particle, "modulate:a", 0.0, 0.5)
			tween.set_parallel(false)
			tween.tween_callback(particle.queue_free)
	var tween2 = create_tween()
	tween2.tween_property(self, "scale", Vector2(3.5, 3.5), 0.1)
	tween2.tween_property(self, "scale", Vector2(0.0, 0.0), 0.25)
	tween2.tween_callback(_on_death_complete)

func _on_death_complete():
	SaveManager.register_codex_discovered(get_codex_id())
	var killer = null
	if has_meta("killer"):
		killer = get_meta("killer")
	if killer == null:
		killer = _get_nearest_player()
	if killer:
		killer.on_enemy_killed(global_position)
	if randf() < XP_DROP_CHANCE:
		for i in 5:
			var orb = ObjectPool.get_object("res://effects/xp_orb.tscn")
			orb.init(XP_VALUE / 5, global_position + Vector2(randf_range(-40, 40), randf_range(-40, 40)))
	queue_free()
