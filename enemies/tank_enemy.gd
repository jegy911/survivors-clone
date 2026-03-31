extends EnemyBase

func _ready():
	super._ready()
	BASE_SPEED = 32.0
	DAMAGE = 25
	XP_VALUE = 20
	XP_DROP_CHANCE = 0.85
	hp = 200
	max_hp = 200
	gold_value = 3
	elite_gold_value = 6
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
		player.take_damage(DAMAGE)
		damage_cooldown = 1.5

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
