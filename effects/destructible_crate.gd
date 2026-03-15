extends Node2D

var hp = 3
var body_rect: ColorRect
var powerups = ["bounce", "speed", "damage", "heal"]

func _ready():
	add_to_group("env_objects")
	body_rect = ColorRect.new()
	body_rect.size = Vector2(24, 24)
	body_rect.position = Vector2(-12, -12)
	body_rect.color = Color("#8B6914")
	add_child(body_rect)
	
	var border = ColorRect.new()
	border.size = Vector2(24, 24)
	border.position = Vector2(-12, -12)
	border.color = Color("#FFD700")
	border.modulate.a = 0.3
	add_child(border)

func _process(_delta):
	if hp <= 0:
		return
	var bullets = get_tree().get_nodes_in_group("player_bullets")
	for b in bullets:
		if global_position.distance_to(b.global_position) < 20:
			_hit()
			return

func _hit():
	hp -= 1
	var tween = body_rect.create_tween()
	tween.tween_property(body_rect, "modulate:a", 0.3, 0.05)
	tween.tween_property(body_rect, "modulate:a", 1.0, 0.05)
	if hp <= 0:
		_break()

func _break():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		powerups.shuffle()
		var chosen = powerups[0]
		match chosen:
			"bounce":
				player.bounce_timer = 5.0
				player.show_floating_text("⚡ BOUNCE BULLET! 5sn", global_position + Vector2(0, -40), Color("#FFD700"), 16)
			"speed":
				player.SPEED += 30
				await get_tree().create_timer(5.0).timeout
				if is_instance_valid(player):
					player.SPEED -= 30
				player.show_floating_text("💨 HIZ! 5sn", global_position + Vector2(0, -40), Color("#00FF00"), 16)
			"damage":
				player.bullet_damage += 15
				await get_tree().create_timer(5.0).timeout
				if is_instance_valid(player):
					player.bullet_damage -= 15
				player.show_floating_text("⚔ GÜÇ! 5sn", global_position + Vector2(0, -40), Color("#E74C3C"), 16)
			"heal":
				player.heal(int(player.max_hp * 0.20))
	
	var burst = create_tween()
	burst.tween_property(self, "scale", Vector2(1.5, 1.5), 0.08)
	burst.tween_property(self, "modulate:a", 0.0, 0.15)
	burst.tween_callback(queue_free)
