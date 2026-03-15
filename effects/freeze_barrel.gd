extends Node2D

var triggered = false
var body_rect: ColorRect

func _ready():
	add_to_group("env_objects")
	body_rect = ColorRect.new()
	body_rect.size = Vector2(22, 22)
	body_rect.position = Vector2(-11, -11)
	body_rect.color = Color("#4A90E2")
	add_child(body_rect)
	
	var pulse = body_rect.create_tween()
	pulse.set_loops()
	pulse.tween_property(body_rect, "modulate:a", 0.6, 0.5)
	pulse.tween_property(body_rect, "modulate:a", 1.0, 0.5)

func _process(_delta):
	if triggered:
		return
	var bullets = get_tree().get_nodes_in_group("player_bullets")
	for b in bullets:
		if global_position.distance_to(b.global_position) < 18:
			_explode()
			return

func _explode():
	triggered = true
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if global_position.distance_to(enemy.global_position) < 130:
			if enemy.has_method("apply_slow"):
				enemy.apply_slow(0.2, 3.0)
	
	var cloud = ColorRect.new()
	cloud.size = Vector2(260, 260)
	cloud.position = Vector2(-130, -130)
	cloud.color = Color("#4A90E2")
	cloud.modulate.a = 0.45
	cloud.z_index = -1
	get_parent().add_child(cloud)
	cloud.global_position = global_position - Vector2(130, 130)
	var tween = cloud.create_tween()
	tween.tween_property(cloud, "modulate:a", 0.0, 1.8)
	tween.tween_callback(cloud.queue_free)
	
	queue_free()
