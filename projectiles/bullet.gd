extends Area2D

var speed = 400.0
var direction = Vector2.ZERO
var damage = 10
var lifetime = 2.0
var armor_piercing = false

func _ready():
	$ColorRect.color = Color("#FFD700")

func _physics_process(delta):
	position += direction * speed * delta
	lifetime -= delta
	
	if lifetime <= 0:
		queue_free()
		return
	
	var areas = get_overlapping_areas()
	for area in areas:
		if area.has_method("take_damage"):
			if not area.is_in_group("player"):
				if armor_piercing:
					area.hp -= damage
					if area.hp <= 0:
						area.die()
					else:
						area.flash()
				else:
					area.take_damage(damage)
				queue_free()
				return

func init(dir: Vector2, dmg: int = 10, is_armor_piercing: bool = false):
	direction = dir
	damage = dmg
	armor_piercing = is_armor_piercing
