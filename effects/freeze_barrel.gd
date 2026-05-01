extends Node2D

const BARREL_TEX := preload("res://assets/effects/freeze_barrel_icon.png")
const BURST_TEX := preload("res://assets/effects/freeze_burst.png")

var triggered = false
var body_visual: CanvasItem


func _ready():
	add_to_group("env_objects")
	var spr := Sprite2D.new()
	spr.texture = BARREL_TEX
	spr.centered = true
	var dim: float = maxf(float(BARREL_TEX.get_width()), 1.0)
	var sc: float = 104.0 / dim
	spr.scale = Vector2(sc, sc)
	body_visual = spr
	add_child(spr)
	var pulse = spr.create_tween()
	pulse.set_loops()
	pulse.tween_property(spr, "modulate:a", 0.65, 0.5)
	pulse.tween_property(spr, "modulate:a", 1.0, 0.5)


func _process(_delta):
	if triggered:
		return
	var bullets = get_tree().get_nodes_in_group("player_bullets")
	for b in bullets:
		if global_position.distance_to(b.global_position) < 22:
			_explode()
			return


func _explode():
	triggered = true
	var enemies = EnemyRegistry.get_enemies()
	for enemy in enemies:
		if global_position.distance_to(enemy.global_position) < 130:
			if enemy.has_method("apply_slow"):
				enemy.apply_slow(0.2, 3.0)

	var cloud := Sprite2D.new()
	cloud.texture = BURST_TEX
	cloud.centered = true
	cloud.z_index = -1
	var bd: float = maxf(float(BURST_TEX.get_width()), 1.0)
	var cs: float = 260.0 / bd
	cloud.scale = Vector2(cs, cs)
	cloud.modulate.a = 0.5
	get_parent().add_child(cloud)
	cloud.global_position = global_position
	var tween = cloud.create_tween()
	tween.tween_property(cloud, "modulate:a", 0.0, 1.8)
	tween.tween_callback(cloud.queue_free)

	queue_free()
