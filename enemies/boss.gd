extends EnemyBase

func _ready():
	super._ready()
	BASE_SPEED = 60.0
	DAMAGE = 25
	XP_VALUE = 200
	hp = 500
	max_hp = 500
	death_scale = 1.8
	gold_value = 10
	current_speed = BASE_SPEED
	particle_color = Color("#C0392B")
	body.color = Color("#C0392B")
	AudioManager.play_boss()

func _process(delta):
	if is_dead or player == null:
		return
	var direction = (player.global_position - global_position).normalized()
	global_position += direction * BASE_SPEED * delta
	damage_cooldown -= delta
	if global_position.distance_to(player.global_position) < 60 and damage_cooldown <= 0:
		player.take_damage(DAMAGE)
		damage_cooldown = 1.0

func _try_drop_gold():
	var orb = ObjectPool.get_object("res://effects/gold_orb.tscn")
	var value = gold_value
	var player_node = get_tree().get_first_node_in_group("player")
	if player_node and player_node.active_items.has("luck_stone"):
		value += player_node.active_items["luck_stone"].gold_bonus
	orb.init(value, global_position)

func flash():
	var tween = create_tween()
	body.color = Color.WHITE
	tween.tween_property(body, "color", Color("#C0392B"), 0.12)

func _on_death_complete():
	var player_node = get_tree().get_first_node_in_group("player")
	if player_node:
		player_node.add_kill()
		player_node.on_enemy_killed(global_position)
	for i in 20:
		var orb = ObjectPool.get_object("res://effects/xp_orb.tscn")
		orb.init(XP_VALUE / 20, global_position + Vector2(randf_range(-60, 60), randf_range(-60, 60)))
	queue_free()
