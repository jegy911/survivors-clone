extends Area2D

## Editörde `Sprite2D.texture` doluysa o kullanılır; değilse bu yol yüklenir.
const ICE_TEXTURE_PATH := "res://assets/projectiles/ice_ball/ice_ball_projectile.png"

const ACTIVE_LAYER := 1
const ACTIVE_MASK := 2

var player = null
var speed = 280.0
var direction = Vector2.ZERO
var damage = 15
var lifetime = 2.5
var _was_crit_shot: bool = false

@onready var body = $ColorRect

static var _ice_tex: Texture2D
static var _ice_tex_ready: bool = false


static func _ice_texture() -> Texture2D:
	if _ice_tex_ready:
		return _ice_tex
	_ice_tex_ready = true
	if ResourceLoader.exists(ICE_TEXTURE_PATH):
		_ice_tex = load(ICE_TEXTURE_PATH) as Texture2D
	return _ice_tex


func _apply_visuals() -> void:
	var spr := get_node_or_null("Sprite2D") as Sprite2D
	var tex_file: Texture2D = _ice_texture()
	if spr == null:
		return
	if spr.texture == null and tex_file != null:
		spr.texture = tex_file
	if spr.texture != null:
		spr.visible = true
		body.visible = false
	else:
		spr.visible = false
		body.visible = true


func _ready():
	body.color = Color("#00BFFF")
	_apply_visuals()


func _physics_process(delta):
	if not visible:
		return
	lifetime -= delta
	if lifetime <= 0:
		ObjectPool.return_object(self)
		return
	position += direction * speed * delta
	rotation = direction.angle()
	for area in get_overlapping_areas():
		if area.has_method("take_damage") and not area.is_in_group("player"):
			var hc: Vector2 = area.global_position if area is Node2D else global_position
			if _was_crit_shot and player != null:
				EventBus.hit_stop_requested.emit(2)
				var par_hit: Node = player.get_parent()
				if par_hit:
					CombatProjectileFx.spawn_crit_burst(par_hit, hc + Vector2(0, -26), player as Node2D)
				if player.has_method("show_floating_text"):
					player.show_floating_text(tr("ui.player.crit_floating"), hc + Vector2(0, -48), Color("#FFD700"), 24)
				_was_crit_shot = false
			area.take_damage(damage)
			if player:
				EventBus.on_damage_dealt.emit(player, area, damage)
			if area.has_method("apply_slow"):
				area.apply_slow(0.3, 2.0)
			if SaveManager.is_heavy_vfx_enabled():
				_spawn_freeze_effect()
			ObjectPool.return_object(self)
			return

func init(dir: Vector2, dmg: int, shooter = null, crit_roll: bool = false):
	player = shooter
	direction = dir
	damage = dmg
	_was_crit_shot = crit_roll
	lifetime = 2.5
	rotation = 0.0
	var vfx_a = player.get_player_vfx_opacity() if player else 1.0
	body.modulate.a = vfx_a
	var spr := get_node_or_null("Sprite2D") as Sprite2D
	if spr:
		spr.modulate.a = vfx_a
	_apply_visuals()
	collision_layer = ACTIVE_LAYER
	collision_mask = ACTIVE_MASK
	show()

func reset():
	direction = Vector2.ZERO
	damage = 15
	_was_crit_shot = false
	lifetime = 2.5
	body.modulate.a = 1.0
	var spr := get_node_or_null("Sprite2D") as Sprite2D
	if spr:
		spr.modulate.a = 1.0
	collision_layer = 0
	collision_mask = 0
	hide()

func _spawn_freeze_effect():
	var vfx_a = player.get_player_vfx_opacity() if player else 1.0
	for i in 5:
		var particle = ColorRect.new()
		particle.size = Vector2(6, 6)
		particle.color = Color("#00BFFF")
		particle.modulate.a = vfx_a
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
