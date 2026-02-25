extends Area2D

var value = 1
var attracted = false
var attract_speed = 0.0
var player = null

@onready var body = $ColorRect

func _ready():
	body.color = Color("#FFD700")
	body.size = Vector2(12, 12)
	body.position = Vector2(-6, -6)
	z_index = 10

func _process(delta):
	if not visible:
		return
	
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		return
	
	var dist = global_position.distance_to(player.global_position)
	var effective_range = 80.0 + player.get_magnet_bonus()
	
	if dist < effective_range:
		attracted = true
	
	if attracted:
		attract_speed = min(attract_speed + 400 * delta, 500)
		var dir = (player.global_position - global_position).normalized()
		global_position += dir * attract_speed * delta
		
		if dist < 15:
			player.collect_gold(value)
			ObjectPool.return_object(self)

func init(gold_value: int, pos: Vector2):
	value = gold_value
	attracted = false
	attract_speed = 0.0
	player = null
	global_position = pos
	
	var tween = create_tween()
	tween.tween_property(self, "global_position", pos + Vector2(randf_range(-15, 15), randf_range(-15, 15)), 0.25)
	show()

func reset():
	value = 1
	attracted = false
	attract_speed = 0.0
	player = null
	hide()
