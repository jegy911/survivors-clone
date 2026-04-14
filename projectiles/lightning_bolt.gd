extends Area2D
## Havuzlanan yıldırım: görsel olarak kamera üstünden hedefe dikey iner; isabette hasar + `lightning_hit_fx`.

signal strike_finished

@onready var _sprite: Sprite2D = $Sprite2D

const BOLT_LAYER: int = 4
const BOLT_MASK: int = 2

var _speed: float = 1100.0
var _target: Node = null
var _dmg: int = 0
var _shooter: Node = null
var _style: StringName = &"lightning"
var _hit: bool = false


func _ready() -> void:
	_restore_collision()


func reset() -> void:
	_hit = false
	_target = null
	_shooter = null
	if _sprite:
		_sprite.rotation = 0.0
	hide()
	_restore_collision()


func _restore_collision() -> void:
	collision_layer = BOLT_LAYER
	collision_mask = BOLT_MASK


func init(_from_global: Vector2, target_enemy: Node, dmg: int, shooter: Node, style: StringName = &"lightning") -> void:
	_target = target_enemy
	_dmg = dmg
	_shooter = shooter
	_style = style
	_hit = false
	_restore_collision()
	if target_enemy is Node2D:
		global_position = _sky_spawn_global((target_enemy as Node2D).global_position)
	else:
		global_position = _from_global
	show()


func _sky_spawn_global(target_global: Vector2) -> Vector2:
	var cam: Camera2D = get_viewport().get_camera_2d()
	if cam == null:
		return Vector2(target_global.x, target_global.y - 720.0)
	var half_h: float = (get_viewport().get_visible_rect().size.y * 0.5) / maxf(cam.zoom.y, 0.001)
	var margin: float = 140.0
	var top_y: float = cam.global_position.y - half_h - margin
	return Vector2(target_global.x, top_y)


func _physics_process(delta: float) -> void:
	if not visible or _hit:
		return
	if _target == null or not is_instance_valid(_target):
		_finish_without_hit()
		return
	var n2: Node2D = _target as Node2D
	if n2 == null:
		_finish_without_hit()
		return
	var to: Vector2 = n2.global_position
	global_position = global_position.move_toward(to, _speed * delta)
	## Doku dosyasında şimşek dikey; `delta_pos.angle()` (~π/2) onu yatay çeviriyordu.
	if _sprite:
		_sprite.rotation = 0.0
	if global_position.distance_to(to) < 20.0:
		_apply_hit(n2)


func _apply_hit(target: Node) -> void:
	if _hit:
		return
	_hit = true
	collision_layer = 0
	collision_mask = 0
	if is_instance_valid(target) and target.has_method("take_damage"):
		target.take_damage(_dmg, _shooter if is_instance_valid(_shooter) else null)
	if is_instance_valid(_shooter):
		EventBus.on_damage_dealt.emit(_shooter, target, _dmg)
	var fx_pos: Vector2 = target.global_position if is_instance_valid(target) else global_position
	var par: Node = target.get_parent() if is_instance_valid(target) else get_parent()
	var shooter2d: Node2D = _shooter if _shooter is Node2D else null
	if par:
		CombatProjectileFx.spawn_lightning_style_flash(par, fx_pos, shooter2d, _style)
	strike_finished.emit()
	ObjectPool.return_object(self)


func _finish_without_hit() -> void:
	if _hit:
		return
	_hit = true
	strike_finished.emit()
	ObjectPool.return_object(self)
