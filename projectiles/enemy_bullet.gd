extends Area2D

var speed = 250.0
var direction = Vector2.ZERO
var damage = 12
var lifetime = 3.0

func _ready():
	pass

func _physics_process(delta):
	position += direction * speed * delta
	lifetime -= delta
	if lifetime <= 0:
		queue_free()
		return
	
	for area in get_overlapping_areas():
		if area.is_in_group("player"):
			area.take_damage(damage)
			queue_free()
			return

func init(dir: Vector2, dmg: int = 12):
	direction = dir
	damage = dmg
