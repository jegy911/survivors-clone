extends Area2D

var speed = 250.0
var direction = Vector2.ZERO
var damage = 12
var lifetime = 3.0

func _physics_process(delta):
	if not visible:
		return
	position += direction * speed * delta
	lifetime -= delta
	if lifetime <= 0:
		ObjectPool.return_object(self)
		return
	for area in get_overlapping_areas():
		if area.is_in_group("player"):
			area.take_damage(damage)
			ObjectPool.return_object(self)
			return

func init(dir: Vector2, dmg: int = 12):
	direction = dir
	damage = dmg
	lifetime = 3.0
	show()

func reset():
	direction = Vector2.ZERO
	damage = 12
	lifetime = 3.0
	hide()
