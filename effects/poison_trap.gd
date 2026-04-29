extends Node2D

const TRAP_TEX := preload("res://assets/effects/poison_trap.png")
const BURST_TEX := preload("res://assets/effects/poison_burst.png")

var triggered = false
var body_visual: CanvasItem

func _ready():
	add_to_group("env_objects")
	var spr := Sprite2D.new()
	spr.texture = TRAP_TEX
	spr.centered = true
	var dim: float = maxf(float(TRAP_TEX.get_width()), 1.0)
	var sc: float = 28.0 / dim
	spr.scale = Vector2(sc, sc)
	body_visual = spr
	add_child(spr)
	
	var pulse = body_visual.create_tween()
	pulse.set_loops()
	pulse.tween_property(body_visual, "modulate:a", 0.5, 0.6)
	pulse.tween_property(body_visual, "modulate:a", 1.0, 0.6)

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
	var enemies = EnemyRegistry.get_enemies()
	for enemy in enemies:
		if global_position.distance_to(enemy.global_position) < 110:
			if enemy.has_method("apply_poison"):
				enemy.apply_poison(8, 4.0)
	
	var cloud := Sprite2D.new()
	cloud.texture = BURST_TEX
	cloud.centered = true
	var bd: float = maxf(float(BURST_TEX.get_width()), 1.0)
	var cs: float = 220.0 / bd
	cloud.scale = Vector2(cs, cs)
	cloud.modulate = Color(0.8, 1.0, 0.8, 0.4)
	cloud.z_index = -1
	get_parent().add_child(cloud)
	cloud.global_position = global_position
	var tween = cloud.create_tween()
	tween.tween_property(cloud, "modulate:a", 0.0, 2.0)
	tween.tween_callback(cloud.queue_free)
	
	queue_free()
