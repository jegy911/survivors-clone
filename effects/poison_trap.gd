extends Node2D

var triggered = false
var body_rect: ColorRect

func _ready():
	add_to_group("env_objects")
	body_rect = ColorRect.new()
	body_rect.size = Vector2(22, 22)
	body_rect.position = Vector2(-11, -11)
	body_rect.color = Color("#27AE60")
	add_child(body_rect)
	
	var pulse = body_rect.create_tween()
	pulse.set_loops()
	pulse.tween_property(body_rect, "modulate:a", 0.5, 0.6)
	pulse.tween_property(body_rect, "modulate:a", 1.0, 0.6)

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
		if global_position.distance_to(enemy.global_position) < 110:
			if enemy.has_method("apply_poison"):
				enemy.apply_poison(8, 4.0)
	
	var cloud = ColorRect.new()
	cloud.size = Vector2(220, 220)
	cloud.color = Color("#27AE60")
	cloud.modulate.a = 0.4
	cloud.z_index = -1
	get_parent().add_child(cloud)
	cloud.global_position = global_position - Vector2(110, 110)
	var tween = cloud.create_tween()
	tween.tween_property(cloud, "modulate:a", 0.0, 2.0)
	tween.tween_callback(cloud.queue_free)
	
	queue_free()
