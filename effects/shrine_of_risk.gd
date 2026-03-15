extends Node2D

var active = true
var body_rect: ColorRect

func _ready():
	body_rect = ColorRect.new()
	body_rect.size = Vector2(26, 26)
	body_rect.position = Vector2(-13, -13)
	body_rect.color = Color("#9B59B6")
	add_child(body_rect)
	
	var label = Label.new()
	label.text = "⚠"
	label.position = Vector2(-8, -30)
	add_child(label)
	
	var pulse = body_rect.create_tween()
	pulse.set_loops()
	pulse.tween_property(body_rect, "modulate:a", 0.4, 0.4)
	pulse.tween_property(body_rect, "modulate:a", 1.0, 0.4)

func _process(_delta):
	if not active:
		return
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	if global_position.distance_to(player.global_position) < 25:
		_activate(player)

func _activate(player: Node):
	active = false
	player.shrine_active = true
	player.shrine_timer = 60.0
	player.show_floating_text("🕯 RİSK SUNAGI! +%200 XP/Gold, düşman +%50", player.global_position + Vector2(0, -70), Color("#9B59B6"), 16)
	
	var tween = body_rect.create_tween()
	tween.tween_property(body_rect, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)
