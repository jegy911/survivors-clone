class_name ItemSpeedCharm
extends PassiveItem

const SPEED_CHARM_FOOT_TEX := preload("res://assets/effects/speed_charm_effect.png")
## Ayak bandı: boost + gerçekten hareket (velocity) iken görünür.
const _MOVE_EPS_SQ := 1600.0
## Sprite origin ile zemin / ayak hizası (CollisionShape2D altına yakın).
const _FOOT_LOCAL := Vector2(0.0, 58.0)

var speed_bonus = 20
var speed_duration = 2.0
var is_boosted = false
var boost_timer = 0.0
var _foot_spr: Sprite2D

func _ready():
	item_name = "Hız Tılsımı"
	description = "Öldürünce geçici hız bonusu"
	category = "utility"
	max_level = 5
	super._ready()
	_setup_foot_vfx()


func _exit_tree() -> void:
	if is_instance_valid(_foot_spr):
		_foot_spr.queue_free()
	_foot_spr = null


func _setup_foot_vfx() -> void:
	if player == null:
		return
	_foot_spr = Sprite2D.new()
	_foot_spr.name = "SpeedCharmFootVfx"
	_foot_spr.texture = SPEED_CHARM_FOOT_TEX
	_foot_spr.centered = true
	_foot_spr.position = _FOOT_LOCAL
	_foot_spr.z_index = -1
	_foot_spr.visible = false
	var tw: float = float(SPEED_CHARM_FOOT_TEX.get_width())
	var sc: float = 52.0 / maxf(tw, 1.0)
	_foot_spr.scale = Vector2(sc, sc)
	player.add_child(_foot_spr)


func _update_foot_vfx() -> void:
	if _foot_spr == null or not is_instance_valid(_foot_spr) or player == null:
		return
	var moving: bool = player.velocity.length_squared() > _MOVE_EPS_SQ
	var show: bool = is_boosted and moving
	_foot_spr.visible = show
	if show:
		var vfx_a: float = player.get_player_vfx_opacity() if player.has_method(&"get_player_vfx_opacity") else 1.0
		_foot_spr.modulate = Color(1.0, 1.0, 1.0, 0.88 * vfx_a)

func apply():
	speed_bonus = 20 + (level - 1) * 10
	speed_duration = 2.0 + (level - 1) * 0.2

func _process(delta):
	if is_boosted:
		boost_timer -= delta
		if boost_timer <= 0:
			is_boosted = false
			player.SPEED -= speed_bonus
	_update_foot_vfx()

func on_enemy_killed(_position: Vector2):
	if not is_boosted:
		is_boosted = true
		boost_timer = speed_duration
		player.SPEED += speed_bonus
		player.show_floating_text("HIZLI!", player.global_position + Vector2(0, -70), Color("#2ECC71"))
	else:
		boost_timer = speed_duration

func get_description() -> String:
	return tr("ui.upgrade_ui.stats.loadout_items.speed_charm") % [
		level,
		speed_bonus,
		snappedf(speed_duration, 0.1),
	]
