extends Area2D

var player = null
var collected = false

@onready var body = $ColorRect

func _ready():
	body.color = Color("#8B4513")
	body.size = Vector2(16, 16)
	body.position = Vector2(-8, -8)
	z_index = 10

func _process(_delta):
	if collected or not visible:
		return
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		return
	var dist = global_position.distance_to(player.global_position)
	if dist < 40:
		_collect()

func _collect():
	if collected:
		return
	collected = true
	set_process(false)
	scale = Vector2.ONE
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "scale", Vector2(1.35, 1.35), 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(body, "modulate", Color(1.2, 1.05, 0.7, 1.0), 0.12)
	tw.set_parallel(false)
	tw.tween_interval(0.08)
	tw.tween_property(self, "scale", Vector2(0.05, 0.05), 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(body, "modulate:a", 0.0, 0.18)
	tw.tween_callback(_finish_chest_open)

func _finish_chest_open():
	if player:
		player.chests_opened += 1
	_give_reward()
	queue_free()

func _give_reward():
	if player == null:
		return
	var roll = randf()
	if roll < 0.5:
		var all_items = ["armor", "speed_charm", "magnet", "lifesteal", "poison", "shield", "crit", "luck_stone", "ember_heart"]
		var item_id = all_items[randi() % all_items.size()]
		player.add_item(item_id)
	elif roll < 0.80:
		player.collect_gold(5 + randi() % 6)
	else:
		player.heal(int(player.max_hp * 0.15))

func init(pos: Vector2):
	global_position = pos
	collected = false
