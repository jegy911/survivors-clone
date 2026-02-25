extends EnemyBase

func _ready():
	super._ready()
	BASE_SPEED = 32.0
	DAMAGE = 8
	XP_VALUE = 7
	XP_DROP_CHANCE = 0.65
	hp = 15
	max_hp = 15
	current_speed = BASE_SPEED
	particle_color = Color("#F1C40F")

func _process(delta):
	if is_dead or player == null:
		return
	if slow_timer > 0:
		slow_timer -= delta
		if slow_timer <= 0:
			current_speed = BASE_SPEED
			body.color = Color("#E74C3C")
	var direction = (player.global_position - global_position).normalized()
	global_position += direction * current_speed * delta
	damage_cooldown -= delta
	if global_position.distance_to(player.global_position) < 35 and damage_cooldown <= 0:
		player.take_damage(DAMAGE)
		damage_cooldown = 0.8

func die():
	if is_dead:
		return
	var player_node = get_tree().get_first_node_in_group("player")
	if player_node:
		player_node.on_tank_killed()
	super.die()

func flash():
	var tween = create_tween()
	body.color = Color.WHITE
	tween.tween_property(body, "color", Color("#E74C3C"), 0.12)
