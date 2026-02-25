extends Area2D

var speed = 280.0
var direction = Vector2.ZERO
var damage = 15
var lifetime = 2.5

@onready var body = $ColorRect

func _ready():
	body.color = Color("#00BFFF")

func init(dir: Vector2, dmg: int):
	direction = dir
	damage = dmg

func _physics_process(delta):
	lifetime -= delta
	if lifetime <= 0:
		queue_free()
		return
	
	position += direction * speed * delta
	rotation = direction.angle()
	
	for area in get_overlapping_areas():
		if area.has_method("take_damage") and not area.is_in_group("player"):
			area.take_damage(damage)
			if area.has_method("apply_slow"):
				area.apply_slow(0.3, 2.0)
			_spawn_freeze_effect()
			queue_free()
			return

func _spawn_freeze_effect():
	for i in 5:
		var particle = ColorRect.new()
		particle.size = Vector2(6, 6)
		particle.color = Color("#00BFFF")
		particle.position = global_position
		get_parent().add_child(particle)
		var angle = (float(i) / 5.0) * TAU
		var target = global_position + Vector2(cos(angle), sin(angle)) * randf_range(20, 40)
		var tween = particle.create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "position", target, 0.3)
		tween.tween_property(particle, "modulate:a", 0.0, 0.3)
		tween.set_parallel(false)
		tween.tween_callback(particle.queue_free)
