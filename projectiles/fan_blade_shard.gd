extends Area2D

## Editörde atanmış `Sprite2D.texture` önceliklidir; yoksa bu yol denenir (uç +X yönünde çizilmiş shard PNG).
const SHARD_TEXTURE_PATH := "res://assets/projectiles/fan_blade/shard.png"
const EMBER_SHARD_TEXTURE_PATH := "res://assets/projectiles/fan_blade/ember_shard.png"

var speed: float = 260.0
var direction: Vector2 = Vector2.ZERO
var damage: int = 10
var lifetime: float = 0.2
var player: Node = null
var _hit: bool = false
var _pierce_remaining: int = 0
var _base_modulate: Color = Color(1, 1, 1, 1)
var _traveled: float = 0.0
var _max_travel: float = 0.0
var _use_ember_shard_texture: bool = false
var _was_crit_roll: bool = false

static var _shard_tex: Texture2D
static var _shard_tex_ready: bool = false


static func _shard_texture() -> Texture2D:
	if _shard_tex_ready:
		return _shard_tex
	_shard_tex_ready = true
	if ResourceLoader.exists(SHARD_TEXTURE_PATH):
		_shard_tex = load(SHARD_TEXTURE_PATH) as Texture2D
	return _shard_tex


func _apply_visuals() -> void:
	var spr := get_node_or_null("Sprite2D") as Sprite2D
	var poly := get_node_or_null("Polygon2D") as Polygon2D
	var tex_file: Texture2D = null
	if _use_ember_shard_texture and ResourceLoader.exists(EMBER_SHARD_TEXTURE_PATH):
		tex_file = load(EMBER_SHARD_TEXTURE_PATH) as Texture2D
	if tex_file == null:
		tex_file = _shard_texture()
	if spr != null:
		if tex_file != null:
			spr.texture = tex_file
		if spr.texture != null:
			spr.visible = true
			spr.modulate = _base_modulate
			if poly != null:
				poly.visible = false
		elif poly != null:
			spr.visible = false
			poly.visible = true
			poly.modulate = _base_modulate
	elif poly != null:
		poly.visible = true
		poly.modulate = _base_modulate


func _ready():
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D):
	if _hit:
		return
	if not area.has_method("take_damage"):
		return
	if area.is_in_group("player"):
		return
	var hit_center: Vector2 = area.global_position if area is Node2D else global_position
	if _was_crit_roll and is_instance_valid(player):
		EventBus.hit_stop_requested.emit(2)
		var par_hit: Node = get_parent()
		if par_hit:
			CombatProjectileFx.spawn_crit_burst(par_hit, hit_center + Vector2(0, -26), player as Node2D)
		player.show_floating_text(tr("ui.player.crit_floating"), hit_center + Vector2(0, -50), Color("#FFD700"), 24)
		_was_crit_roll = false
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
	if collision_layer == 0:
		return
	var step: float = speed * delta
	var remaining: float = _max_travel - _traveled
	if remaining <= 0.0:
		ObjectPool.return_object(self)
		return
	step = minf(step, remaining)
	position += direction * step
	_traveled += step
	lifetime -= delta
	if _traveled >= _max_travel - 0.0001 or lifetime <= 0.0:
		ObjectPool.return_object(self)


func init(
	dir: Vector2,
	dmg: int,
	shooter: Node,
	pierce: int = 0,
	tint: Color = Color(0.95, 0.35, 0.08, 1.0),
	move_speed: float = 260.0,
	life: float = 0.2,
	use_ember_shard_texture: bool = false,
	crit_roll: bool = false
):
	_hit = false
	_was_crit_roll = crit_roll
	_use_ember_shard_texture = use_ember_shard_texture
	_pierce_remaining = pierce
	direction = dir.normalized()
	if direction.length_squared() < 0.001:
		direction = Vector2.RIGHT
	damage = dmg
	player = shooter
	speed = maxf(move_speed, 1.0)
	lifetime = maxf(life, 0.0001)
	_traveled = 0.0
	_max_travel = speed * lifetime
	var vfx_a: float = 1.0
	if shooter and shooter.has_method("get_player_vfx_opacity"):
		vfx_a = shooter.get_player_vfx_opacity()
	_base_modulate = Color(tint.r, tint.g, tint.b, tint.a * vfx_a)
	collision_layer = 4
	collision_mask = 2
	monitoring = true
	_apply_visuals()
	rotation = direction.angle()
	add_to_group("player_bullets")
	show()


func reset():
	_hit = false
	_was_crit_roll = false
	_use_ember_shard_texture = false
	direction = Vector2.ZERO
	damage = 10
	lifetime = 0.2
	speed = 260.0
	player = null
	_pierce_remaining = 0
	rotation = 0.0
	_traveled = 0.0
	_max_travel = 0.0
	_base_modulate = Color(0.95, 0.35, 0.08, 1)
	# `collision_layer` 0 yeterli; `set_deferred("monitoring", false)` kuyrukta kalıp sonraki `init()` ile yarışabiliyordu.
	collision_layer = 0
	collision_mask = 0
	var spr := get_node_or_null("Sprite2D") as Sprite2D
	if spr != null:
		var def_tex: Texture2D = _shard_texture()
		if def_tex != null:
			spr.texture = def_tex
		spr.modulate = _base_modulate
	var poly := get_node_or_null("Polygon2D") as Polygon2D
	if poly != null:
		poly.modulate = _base_modulate
	remove_from_group("player_bullets")
	hide()
