extends EnemyBase

func _ready():
	super._ready()
	BASE_SPEED = 28.0
	DAMAGE = 40
	XP_VALUE = 25
	XP_DROP_CHANCE = 0.95
	hp = 400
	max_hp = 400
	gold_value = 5
	elite_gold_value = 10
	current_speed = BASE_SPEED
	particle_color = Color("#9B59B6")
	body.color = Color("#9B59B6")
	scale = Vector2(1.5, 1.5)

func _process(delta):
	player = _get_nearest_player()
	if is_dead or player == null:
		return
	if slow_timer > 0:
		slow_timer -= delta
		if slow_timer <= 0:
			current_speed = BASE_SPEED
			body.color = Color("#9B59B6")
	var direction = (player.global_position - global_position).normalized()
	global_position += direction * current_speed * delta
	damage_cooldown -= delta
	if global_position.distance_to(player.global_position) < 50 and damage_cooldown <= 0:
		player.take_damage(DAMAGE, self)
		damage_cooldown = 1.5

	_update_enemy_direction()

func die(killer: Node = null):
	if is_dead:
		return
	var players = get_tree().get_nodes_in_group("player")
	for p in players:
		p.on_tank_killed()
	super.die(killer)

func flash():
	var tween = create_tween()
	body.color = Color.WHITE
	tween.tween_property(body, "color", Color("#9B59B6"), 0.12)
