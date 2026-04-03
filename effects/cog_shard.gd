extends Area2D

var attract_speed = 0.0
var attracted = false

func _ready():
	add_to_group("cog_shards")
	var body = get_node_or_null("ColorRect")
	if body:
		body.color = Color("#B0C4DE")
		body.size = Vector2(12, 12)
		body.position = Vector2(-6, -6)
	z_index = 10

func _process(delta):
	if not visible:
		return
	var nearest = _get_nearest_player()
	if nearest == null:
		return
	var dist = global_position.distance_to(nearest.global_position)
	var effective_range = 80.0 + nearest.get_magnet_bonus()
	if dist < effective_range:
		attracted = true
	if attracted:
		attract_speed = min(attract_speed + 400 * delta, 500)
		var dir = (nearest.global_position - global_position).normalized()
		global_position += dir * attract_speed * delta
	var all_players = get_tree().get_nodes_in_group("player")
	for p in all_players:
		if global_position.distance_to(p.global_position) < 15:
			p.collect_cog_shard()
			queue_free()
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

func init(pos: Vector2):
	attracted = false
	attract_speed = 0.0
	global_position = pos
	var tween = create_tween()
	tween.tween_property(self, "global_position", pos + Vector2(randf_range(-15, 15), randf_range(-20, -5)), 0.25)
	show()
