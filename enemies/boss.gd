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
	player = _get_nearest_player()
	if is_dead or player == null:
		return
	var direction = (player.global_position - global_position).normalized()
	global_position += direction * BASE_SPEED * delta
	damage_cooldown -= delta
	if global_position.distance_to(player.global_position) < 60 and damage_cooldown <= 0:
		player.take_damage(DAMAGE)
		damage_cooldown = 1.0

func die(killer: Node = null):
	var players = get_tree().get_nodes_in_group("player")
	for p in players:
		p.boss_kill_count += 1
	super.die(killer)

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
		player_node.on_enemy_killed(global_position)
	for i in 20:
		var orb = ObjectPool.get_object("res://effects/xp_orb.tscn")
		orb.init(XP_VALUE / 20, global_position + Vector2(randf_range(-60, 60), randf_range(-60, 60)))
	_spawn_boss_chest()
	queue_free()

func _spawn_boss_chest():
	var chest_node = Node2D.new()
	get_parent().add_child(chest_node)
	chest_node.global_position = global_position
	
	var body_rect = ColorRect.new()
	body_rect.size = Vector2(28, 28)
	body_rect.position = Vector2(-14, -14)
	body_rect.color = Color("#8B4513")
	chest_node.add_child(body_rect)
	
	# Titreme + ışık efekti
	var tween = chest_node.create_tween()
	tween.set_loops(6)
	tween.tween_property(body_rect, "color", Color("#FFD700"), 0.15)
	tween.tween_property(body_rect, "color", Color("#8B4513"), 0.15)
	tween.set_loops(0)
	
	var shake_tween = chest_node.create_tween()
	shake_tween.set_loops(12)
	shake_tween.tween_property(chest_node, "position", chest_node.position + Vector2(4, 0), 0.06)
	shake_tween.tween_property(chest_node, "position", chest_node.position + Vector2(-4, 0), 0.06)
	shake_tween.set_loops(0)
	
	# Işın efektleri
	for i in 8:
		var ray = ColorRect.new()
		ray.size = Vector2(4, 40)
		ray.color = Color("#FFD700")
		ray.modulate.a = 0.8
		ray.pivot_offset = Vector2(2, 40)
		ray.rotation = (float(i) / 8.0) * TAU
		ray.position = Vector2(-2, -14)
		chest_node.add_child(ray)
		var ray_tween = ray.create_tween()
		ray_tween.set_loops()
		ray_tween.tween_property(ray, "modulate:a", 0.1, 0.4)
		ray_tween.tween_property(ray, "modulate:a", 0.8, 0.4)
	
	# 2.5 sn sonra aç
	await get_tree().create_timer(2.5).timeout
	if not is_instance_valid(chest_node):
		return
	
	var player_node = get_tree().get_first_node_in_group("player")
	if player_node:
		var reward_count = randi_range(3, 5)
		player_node.show_floating_text("📦 BOSS SANDIĞI x" + str(reward_count) + "!", chest_node.global_position + Vector2(0, -60), Color("#FFD700"), 22)
		var items = ["lifesteal", "armor", "crit", "shield", "explosion", "magnet", "poison", "speed_charm"]
		items.shuffle()
		for i in min(reward_count, items.size()):
			player_node.add_item(items[i])
	
	# Patlama efekti — chest_node hâlâ valid mi kontrol et
	if not is_instance_valid(chest_node):
		return
	var burst = chest_node.create_tween()
	burst.tween_property(chest_node, "scale", Vector2(2.0, 2.0), 0.1)
	burst.tween_property(chest_node, "modulate:a", 0.0, 0.2)
	burst.tween_callback(chest_node.queue_free)
