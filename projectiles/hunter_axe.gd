extends Area2D
## Avcı savrulan balta (oyun içi silah ID: `boomerang`).

const TEX_AXE := preload("res://assets/projectiles/axe/boomerang.png")

var speed = 350.0
var direction = Vector2.ZERO
var damage = 18
var player_ref = null
var returning = false
var hit_enemies = []
var lifetime = 3.0
var lifesteal = false

@onready var body: Sprite2D = $Sprite2D


func _ready() -> void:
	body.texture = TEX_AXE
	body.modulate = Color.WHITE


func _physics_process(delta: float) -> void:
	if not visible:
		return
	lifetime -= delta
	if lifetime <= 0.0:
		ObjectPool.return_object(self)
		return

	if returning:
		if player_ref == null or not is_instance_valid(player_ref):
			ObjectPool.return_object(self)
			return
		direction = (player_ref.global_position - global_position).normalized()
		if global_position.distance_to(player_ref.global_position) < 20.0:
			ObjectPool.return_object(self)
			return

	position += direction * speed * delta
	rotation = direction.angle()
	body.rotation += delta * 14.0

	if not returning and player_ref:
		if global_position.distance_to(player_ref.global_position) > 200.0:
			returning = true
			hit_enemies.clear()

	for area in get_overlapping_areas():
		if area.has_method("take_damage") and not area.is_in_group("player"):
			if not area in hit_enemies:
				area.take_damage(damage)
				hit_enemies.append(area)
				if player_ref:
					EventBus.on_damage_dealt.emit(player_ref, area, damage)
					if lifesteal and player_ref.has_method("heal"):
						var heal_amount: int = maxi(1, int(damage * 0.15))
						player_ref.heal(heal_amount)


func init(dir: Vector2, dmg: int, player: Node2D, steal_life: bool = false) -> void:
	direction = dir
	damage = dmg
	player_ref = player
	lifesteal = steal_life
	returning = false
	hit_enemies.clear()
	lifetime = 3.0
	rotation = 0.0
	body.rotation = 0.0
	var vfx_a: float = 1.0
	if player and player.has_method("get_player_vfx_opacity"):
		vfx_a = player.get_player_vfx_opacity()
	if lifesteal:
		body.modulate = Color(1.0, 0.5, 0.52, vfx_a)
	else:
		body.modulate = Color(1.0, 1.0, 1.0, vfx_a)
	show()


func reset() -> void:
	direction = Vector2.ZERO
	damage = 18
	player_ref = null
	returning = false
	hit_enemies.clear()
	lifetime = 3.0
	lifesteal = false
	body.rotation = 0.0
	body.modulate = Color.WHITE
	body.modulate.a = 1.0
	hide()
