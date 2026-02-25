extends Area2D

var speed = 350.0
var direction = Vector2.ZERO
var damage = 18
var player_ref = null
var returning = false
var hit_enemies = []
var lifetime = 3.0
var lifesteal = false

@onready var body = $ColorRect

func _ready():
	body.color = Color("#00BFFF")
	

func init(dir: Vector2, dmg: int, player: Node2D):
	direction = dir
	damage = dmg
	player_ref = player

func _physics_process(delta):
	lifetime -= delta
	if lifetime <= 0:
		queue_free()
		return
	
	if returning:
		if player_ref == null or not is_instance_valid(player_ref):
			queue_free()
			return
		direction = (player_ref.global_position - global_position).normalized()
		if global_position.distance_to(player_ref.global_position) < 20:
			queue_free()
			return
	
	position += direction * speed * delta
	rotation = direction.angle()
	
	if not returning and player_ref:
		if global_position.distance_to(player_ref.global_position) > 200:
			returning = true
			hit_enemies.clear()
	
	for area in get_overlapping_areas():
		if area.has_method("take_damage") and not area.is_in_group("player"):
			if not area in hit_enemies:
				area.take_damage(damage)
				hit_enemies.append(area)
				if lifesteal and player_ref:
					player_ref.heal(int(damage * 0.3))
