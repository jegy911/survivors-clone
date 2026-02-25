extends EnemyBase

const DASH_SPEED = 380.0
var is_dashing = false
var dash_timer = 0.0
var dash_cooldown = 0.0
var dash_direction = Vector2.ZERO

func _ready():
	super._ready()
	BASE_SPEED = 42.0
	DAMAGE = 18
	XP_VALUE = 9
	XP_DROP_CHANCE = 0.70
	hp = 25
	max_hp = 25
	current_speed = BASE_SPEED
	particle_color = Color("#FF1493")
	body.color = Color("#FF1493")

func _process(delta):
	if is_dead or player == null:
		return
	dash_cooldown -= delta
	damage_cooldown -= delta
	if is_dashing:
		dash_timer -= delta
		global_position += dash_direction * DASH_SPEED * delta
		if dash_timer <= 0:
			is_dashing = false
	else:
		var dist = global_position.distance_to(player.global_position)
		if dash_cooldown <= 0 and dist < 300:
			_start_dash()
		else:
			var direction = (player.global_position - global_position).normalized()
			global_position += direction * BASE_SPEED * delta
	if damage_cooldown <= 0 and global_position.distance_to(player.global_position) < 40:
		player.take_damage(DAMAGE)
		damage_cooldown = 1.2

func _start_dash():
	is_dashing = true
	dash_timer = 0.2
	dash_cooldown = 3.0
	dash_direction = (player.global_position - global_position).normalized()
	body.color = Color("#FF69B4")

func flash():
	var tween = create_tween()
	body.color = Color.WHITE
	tween.tween_property(body, "color", Color("#FF1493"), 0.12)
