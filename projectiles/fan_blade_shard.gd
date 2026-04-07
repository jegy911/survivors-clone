extends Area2D

var speed: float = 260.0
var direction: Vector2 = Vector2.ZERO
var damage: int = 10
var lifetime: float = 0.2
var player: Node = null
var _hit: bool = false
var _pierce_remaining: int = 0
var _base_modulate: Color = Color(1, 1, 1, 1)

func _ready():
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D):
	if _hit:
		return
	if not area.has_method("take_damage"):
		return
	if area.is_in_group("player"):
		return
	area.take_damage(damage, player if is_instance_valid(player) else null)
	if is_instance_valid(player):
		EventBus.on_damage_dealt.emit(player, area, damage)
	if _pierce_remaining > 0:
		_pierce_remaining -= 1
		return
	_hit = true
	ObjectPool.return_object(self)

func _physics_process(delta):
	if not visible:
		return
	position += direction * speed * delta
	lifetime -= delta
	if lifetime <= 0:
		ObjectPool.return_object(self)

func init(
	dir: Vector2,
	dmg: int,
	shooter: Node,
	pierce: int = 0,
	tint: Color = Color(0.95, 0.35, 0.08, 1.0),
	move_speed: float = 260.0,
	life: float = 0.2
):
	_hit = false
	_pierce_remaining = pierce
	direction = dir.normalized()
	if direction.length_squared() < 0.001:
		direction = Vector2.RIGHT
	damage = dmg
	player = shooter
	speed = move_speed
	lifetime = life
	var vfx_a = 1.0
	if shooter and shooter.has_method("get_player_vfx_opacity"):
		vfx_a = shooter.get_player_vfx_opacity()
	_base_modulate = Color(tint.r, tint.g, tint.b, tint.a * vfx_a)
	var poly = get_node_or_null("Polygon2D") as Polygon2D
	if poly:
		poly.modulate = _base_modulate
	rotation = direction.angle()
	add_to_group("player_bullets")
	show()

func reset():
	_hit = false
	direction = Vector2.ZERO
	damage = 10
	lifetime = 0.2
	speed = 260.0
	player = null
	_pierce_remaining = 0
	rotation = 0.0
	var poly = get_node_or_null("Polygon2D") as Polygon2D
	if poly:
		poly.modulate = Color(0.95, 0.35, 0.08, 1)
	remove_from_group("player_bullets")
	hide()
