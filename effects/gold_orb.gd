extends Area2D

var value = 1
var attracted = false
var attract_speed = 0.0
var player = null

func _process(delta):
	if not visible:
		return
	var nearest = _get_nearest_player()
	if nearest == null:
		return
	player = nearest
	var dist = global_position.distance_to(player.global_position)
	var effective_range = 80.0 + player.get_magnet_bonus()
	if dist < effective_range:
		attracted = true
	if attracted:
		attract_speed = min(attract_speed + 400 * delta, 500)
		var dir = (player.global_position - global_position).normalized()
		global_position += dir * attract_speed * delta
	var all_players = get_tree().get_nodes_in_group("player")
	for p in all_players:
		if global_position.distance_to(p.global_position) < 15:
			var p1 = get_tree().get_nodes_in_group("player").filter(
				func(x): return x.player_id == 0)
			if not p1.is_empty():
				p1[0].collect_gold(value)
			ObjectPool.return_object(self)
			return

func _get_nearest_player() -> Node:
	var players = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return null
	var nearest = players[0]
	var nearest_dist = global_position.distance_to(nearest.global_position)
	for p in players:
		var dist = global_position.distance_to(p.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = p
	return nearest

func init(gold_value: int, pos: Vector2):
	value = gold_value
	attracted = false
	attract_speed = 0.0
	player = null
	global_position = pos
	add_to_group("gold_orbs")
	show()
	var tween = create_tween()
	tween.tween_property(self, "global_position", pos + Vector2(randf_range(-15, 15), randf_range(-15, 15)), 0.25)
	await tween.finished
	if is_instance_valid(self) and visible:
		var bob = create_tween()
		bob.set_loops()
		bob.tween_property(self, "position", position + Vector2(0, -4), 0.5).set_trans(Tween.TRANS_SINE)
		bob.tween_property(self, "position", position, 0.5).set_trans(Tween.TRANS_SINE)

func vacuum_attract():
	attracted = true
	attract_speed = 900.0

func reset():
	value = 1
	attracted = false
	attract_speed = 0.0
	player = null
	remove_from_group("gold_orbs")
	hide()
