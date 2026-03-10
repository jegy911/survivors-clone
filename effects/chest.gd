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
	collected = true
	if player:
		player.chests_opened += 1
	_give_reward()
	queue_free()

func _give_reward():
	if player == null:
		return
	var roll = randf()
	if roll < 0.5:
		# %50 — rastgele passive item ver
		var all_items = ["armor", "speed_charm", "magnet", "lifesteal", "poison", "shield", "crit", "luck_stone"]
		var item_id = all_items[randi() % all_items.size()]
		player.add_item(item_id)
	elif roll < 0.80:
		# %30 — gold
		player.collect_gold(5 + randi() % 6)
	else:
		# %20 — HP heal
		player.heal(int(player.max_hp * 0.15))

func init(pos: Vector2):
	global_position = pos
	collected = false
