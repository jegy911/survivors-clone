extends EnemyBase

func _ready():
	super._ready()
	BASE_SPEED = 110.0
	DAMAGE = 8
	XP_VALUE = 7
	XP_DROP_CHANCE = 0.65
	hp = 15
	max_hp = 15
	current_speed = BASE_SPEED
	particle_color = Color("#F1C40F")

func _process(delta):
	player = _get_nearest_player()
	if is_dead or player == null:
		return
	if slow_timer > 0:
		slow_timer -= delta
		if slow_timer <= 0:
			current_speed = BASE_SPEED
			body.color = Color("#F1C40F")
	var direction = (player.global_position - global_position).normalized()
	global_position += direction * current_speed * delta
	_update_enemy_direction()
	damage_cooldown -= delta
	if global_position.distance_to(player.global_position) < 35 and damage_cooldown <= 0:
		player.take_damage(DAMAGE)
		damage_cooldown = 0.8

func flash():
	var tween = create_tween()
	body.color = Color.WHITE
	tween.tween_property(body, "color", Color("#F1C40F"), 0.12)
