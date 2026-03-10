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

func _physics_process(delta):
	if not visible:
		return
	lifetime -= delta
	if lifetime <= 0:
		ObjectPool.return_object(self)
		return
	
	if returning:
		if player_ref == null or not is_instance_valid(player_ref):
			ObjectPool.return_object(self)
			return
		direction = (player_ref.global_position - global_position).normalized()
		if global_position.distance_to(player_ref.global_position) < 20:
			ObjectPool.return_object(self)
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
				if player_ref:
					EventBus.on_damage_dealt.emit(player_ref, area, damage)

func init(dir: Vector2, dmg: int, player: Node2D):
	direction = dir
	damage = dmg
	player_ref = player
	returning = false
	hit_enemies.clear()
	lifetime = 3.0
	rotation = 0.0
	show()

func reset():
	direction = Vector2.ZERO
	damage = 18
	player_ref = null
	returning = false
	hit_enemies.clear()
	lifetime = 3.0
	lifesteal = false
	hide()
