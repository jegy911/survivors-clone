extends Node

const VACUUM_ICON := preload("res://assets/effects/vacuum_collector.png")
const RUIN_TEX_LOW := preload("res://assets/effects/ruin_cache_low.png")
const RUIN_TEX_MID := preload("res://assets/effects/ruin_cache_mid.png")
const RUIN_TEX_HIGH := preload("res://assets/effects/ruin_cache_high.png")

var vacuum_spawn_timer = 120.0
var trap_spawn_timer = 30.0
var shrine_spawn_timer = 90.0
var crate_spawn_timer = 45.0
var ruin_spawn_timer = 180.0

var main_node: Node = null
var _crate_variant_toggle := false

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

	ruin_spawn_timer -= delta
	if ruin_spawn_timer <= 0:
		ruin_spawn_timer = randf_range(150.0, 240.0)
		_spawn_ruin_cache()

func _get_player() -> Node:
	var players = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return null
	return players[randi() % players.size()]

func _get_spawn_pos(min_dist: float, max_dist: float) -> Vector2:
	var player = _get_player()
	if player == null:
		return Vector2.ZERO
	var angle = randf() * TAU
	return player.global_position + Vector2(cos(angle), sin(angle)) * randf_range(min_dist, max_dist)

func _spawn_vacuum_orb():
	var player = _get_player()
	if player == null:
		return
	var orb_node = Node2D.new()
	var body := Sprite2D.new()
	body.texture = VACUUM_ICON
	body.centered = true
	var dim: float = maxf(float(VACUUM_ICON.get_width()), 1.0)
	body.scale = Vector2.ONE * (26.0 / dim)
	body.name = "Body"
	orb_node.add_child(body)
	var area = Area2D.new()
	area.collision_layer = 0
	area.collision_mask = 1
	area.monitorable = true
	area.monitoring = true
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 28.0
	shape.shape = circle
	area.add_child(shape)
	orb_node.add_child(area)
	main_node.add_child(orb_node)
	var angle = randf() * TAU
	orb_node.global_position = player.global_position + Vector2(cos(angle), sin(angle)) * randf_range(100.0, 250.0)
	var pulse = body.create_tween()
	pulse.set_loops()
	pulse.tween_property(body, "modulate:a", 0.45, 0.45)
	pulse.tween_property(body, "modulate:a", 1.0, 0.45)
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
	trap.global_position = _get_spawn_pos(150.0, 350.0)
	await get_tree().create_timer(30.0).timeout
	if is_instance_valid(trap):
		trap.queue_free()

func _spawn_shrine():
	var player = _get_player()
	if player == null:
		return
	var shrine = load("res://effects/shrine_of_risk.gd").new()
	main_node.add_child(shrine)
	shrine.global_position = _get_spawn_pos(200.0, 400.0)
	await get_tree().create_timer(45.0).timeout
	if is_instance_valid(shrine):
		shrine.queue_free()

func _spawn_crate():
	var player = _get_player()
	if player == null:
		return
	var crate = load("res://effects/destructible_crate.gd").new()
	main_node.add_child(crate)
	_crate_variant_toggle = not _crate_variant_toggle
	crate.init_variant("high" if _crate_variant_toggle else "low")
	crate.global_position = _get_spawn_pos(100.0, 300.0)

func _spawn_ruin_cache():
	var player = _get_player()
	if player == null:
		return

	# Enkaz sandığı node'u oluştur
	var ruin = Node2D.new()
	ruin.name = "RuinCache"
	ruin.add_to_group("env_objects")
	var reward_tier := _pick_ruin_tier()

	# Görsel — low/mid/high varyantı
	var body := Sprite2D.new()
	body.name = "BodySprite"
	body.texture = _ruin_texture_for_tier(reward_tier)
	body.centered = true
	var dim: float = maxf(float(body.texture.get_width()), 1.0)
	body.scale = Vector2.ONE * (34.0 / dim)
	ruin.add_child(body)

	var glow := Sprite2D.new()
	glow.texture = _ruin_texture_for_tier(reward_tier)
	glow.centered = true
	glow.scale = body.scale * 1.06
	glow.modulate = Color(1.1, 1.0, 0.7, 1.0)
	glow.modulate.a = 0.25
	ruin.add_child(glow)

	# Nabız efekti
	var pulse = glow.create_tween()
	pulse.set_loops()
	pulse.tween_property(glow, "modulate:a", 0.6, 0.7)
	pulse.tween_property(glow, "modulate:a", 0.1, 0.7)

	# Collision
	var area = Area2D.new()
	area.collision_layer = 0
	area.collision_mask = 1
	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(30, 30)
	shape.shape = rect
	area.add_child(shape)
	ruin.add_child(area)

	main_node.add_child(ruin)
	ruin.global_position = _get_spawn_pos(200.0, 500.0)

	# Oyuncu temas edince aç
	area.body_entered.connect(_on_ruin_opened.bind(ruin, reward_tier))

	# 60 saniye sonra kaybol
	await get_tree().create_timer(60.0).timeout
	if is_instance_valid(ruin):
		var fade = ruin.get_node_or_null("ColorRect")
		if fade:
			var tween = fade.create_tween()
			tween.tween_property(ruin, "modulate:a", 0.0, 1.5)
			tween.tween_callback(ruin.queue_free)

func _on_ruin_opened(body: Node, ruin: Node, reward_tier: String):
	if not is_instance_valid(ruin):
		return
	if not body.is_in_group("player"):
		return

	# Parçalanma efekti
	var burst = ruin.create_tween()
	burst.tween_property(ruin, "scale", Vector2(1.4, 1.4), 0.07)
	burst.tween_property(ruin, "modulate:a", 0.0, 0.15)
	burst.tween_callback(ruin.queue_free)

	# Co-op: her oyuncuya ayrı ayrı ver
	var players = get_tree().get_nodes_in_group("player")
	for p in players:
		_give_ruin_reward(p, reward_tier)

func _give_ruin_reward(player: Node, reward_tier: String):
	# Önce yükseltebileceğimiz silahları bul
	var upgradeable_weapons = []
	for w_id in player.active_weapons:
		var w = player.active_weapons[w_id]
		if w.level < w.max_level:
			upgradeable_weapons.append(w_id)

	# Yükseltebileceğimiz passive itemları bul
	var upgradeable_items = []
	for i_id in player.active_items:
		var i = player.active_items[i_id]
		if i.level < i.max_level:
			upgradeable_items.append(i_id)

	if upgradeable_weapons.is_empty() and upgradeable_items.is_empty():
		# Her şey maxsa altın ver
		var flat_gold := 90 if reward_tier == "high" else (70 if reward_tier == "mid" else 50)
		player.collect_gold(flat_gold)
		player.show_floating_text(
			"⚙ ENKAZ: +%d 💰" % flat_gold,
			player.global_position + Vector2(0, -80),
			Color("#FFD700"), 18
		)
		return

	# Rastgele silah mı item mı?
	var pool = []
	for w in upgradeable_weapons:
		pool.append({"type": "weapon", "id": w})
	for i in upgradeable_items:
		pool.append({"type": "item", "id": i})

	pool.shuffle()
	var chosen = pool[0]
	if reward_tier == "high" and pool.size() > 1:
		# High varyant: ikinci bir ücretsiz yükseltme daha ver.
		var second = pool[1]
		if second["type"] == "weapon":
			player.add_weapon(second["id"])
		else:
			player.add_item(second["id"])

	if chosen["type"] == "weapon":
		player.add_weapon(chosen["id"])
		player.show_floating_text(
			"⚙ ENKAZ: " + chosen["id"].to_upper() + " ↑",
			player.global_position + Vector2(0, -80),
			Color("#FFD700"), 18
		)
	else:
		player.add_item(chosen["id"])
		player.show_floating_text(
			"⚙ ENKAZ: " + chosen["id"].to_upper() + " ↑",
			player.global_position + Vector2(0, -80),
			Color("#FFD700"), 18
		)


func _pick_ruin_tier() -> String:
	var roll := randf()
	if roll < 0.25:
		return "high"
	if roll < 0.70:
		return "mid"
	return "low"


func _ruin_texture_for_tier(reward_tier: String) -> Texture2D:
	match reward_tier:
		"high":
			return RUIN_TEX_HIGH
		"mid":
			return RUIN_TEX_MID
		_:
			return RUIN_TEX_LOW
