extends Node

var vacuum_spawn_timer = 120.0
var trap_spawn_timer = 30.0
var shrine_spawn_timer = 90.0
var crate_spawn_timer = 45.0

var main_node: Node = null

func initialize(main: Node):
	main_node = main

func process(delta: float):
	vacuum_spawn_timer -= delta
	if vacuum_spawn_timer <= 0:
		vacuum_spawn_timer = randf_range(90.0, 150.0)
		_spawn_vacuum_orb()

	trap_spawn_timer -= delta
	if trap_spawn_timer <= 0:
		trap_spawn_timer = randf_range(20.0, 40.0)
		_spawn_trap()

	shrine_spawn_timer -= delta
	if shrine_spawn_timer <= 0:
		shrine_spawn_timer = randf_range(60.0, 120.0)
		_spawn_shrine()

	crate_spawn_timer -= delta
	if crate_spawn_timer <= 0:
		crate_spawn_timer = randf_range(30.0, 60.0)
		_spawn_crate()

func _get_player() -> Node:
	var players = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return null
	# Co-op: rastgele bir oyuncunun etrafına spawn et
	return players[randi() % players.size()]

func _spawn_vacuum_orb():
	var player = _get_player()
	if player == null:
		return
	var orb_node = Node2D.new()
	var body = ColorRect.new()
	body.size = Vector2(20, 20)
	body.position = Vector2(-10, -10)
	body.color = Color("#00FFFF")
	body.name = "Body"
	orb_node.add_child(body)
	var area = Area2D.new()
	area.collision_layer = 0
	area.collision_mask = 1
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 18.0
	shape.shape = circle
	area.add_child(shape)
	orb_node.add_child(area)
	main_node.add_child(orb_node)
	var angle = randf() * TAU
	orb_node.global_position = player.global_position + Vector2(cos(angle), sin(angle)) * randf_range(100.0, 250.0)
	var pulse = body.create_tween()
	pulse.set_loops()
	pulse.tween_property(body, "modulate:a", 0.3, 0.4)
	pulse.tween_property(body, "modulate:a", 1.0, 0.4)
	area.body_entered.connect(_on_vacuum_collected.bind(orb_node, area))

func _on_vacuum_collected(body: Node, orb_node: Node, _area: Node):
	if not is_instance_valid(orb_node):
		return
	if not body.is_in_group("player"):
		return
	var xp_orbs = get_tree().get_nodes_in_group("xp_orbs")
	for xo in xp_orbs:
		if xo.has_method("vacuum_attract"):
			xo.vacuum_attract()
	var gold_orbs = get_tree().get_nodes_in_group("gold_orbs")
	for go in gold_orbs:
		if go.has_method("vacuum_attract"):
			go.vacuum_attract()
	body.show_floating_text("🌀 VAKUM!", orb_node.global_position + Vector2(0, -40), Color("#00FFFF"), 20)
	orb_node.queue_free()
	await get_tree().create_timer(15.0).timeout
	if is_instance_valid(orb_node):
		var fade = orb_node.get_node_or_null("Body")
		if fade:
			var tween = fade.create_tween()
			tween.tween_property(fade, "modulate:a", 0.0, 1.0)
			tween.tween_callback(orb_node.queue_free)

func _spawn_trap():
	var player = _get_player()
	if player == null:
		return
	var trap
	if randf() > 0.5:
		trap = load("res://effects/freeze_barrel.gd").new()
	else:
		trap = load("res://effects/poison_trap.gd").new()
	main_node.add_child(trap)
	var angle = randf() * TAU
	trap.global_position = player.global_position + Vector2(cos(angle), sin(angle)) * randf_range(150.0, 350.0)
	await get_tree().create_timer(30.0).timeout
	if is_instance_valid(trap):
		trap.queue_free()

func _spawn_shrine():
	var player = _get_player()
	if player == null:
		return
	var shrine = load("res://effects/shrine_of_risk.gd").new()
	main_node.add_child(shrine)
	var angle = randf() * TAU
	shrine.global_position = player.global_position + Vector2(cos(angle), sin(angle)) * randf_range(200.0, 400.0)
	await get_tree().create_timer(45.0).timeout
	if is_instance_valid(shrine):
		shrine.queue_free()

func _spawn_crate():
	var player = _get_player()
	if player == null:
		return
	var crate = load("res://effects/destructible_crate.gd").new()
	main_node.add_child(crate)
	var angle = randf() * TAU
	crate.global_position = player.global_position + Vector2(cos(angle), sin(angle)) * randf_range(100.0, 300.0)
