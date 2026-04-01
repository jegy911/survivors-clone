extends EnemyBase

var is_weak = false

func _ready():
	super._ready()
	is_weak = get_meta("weak_mode", false)
	if is_weak:
		hp = 1
		max_hp = 1
	hp = 10
	max_hp = 10
	BASE_SPEED = 55.0
	DAMAGE = 10
	XP_VALUE = 5
	current_speed = BASE_SPEED

func _process(delta):
	player = _get_nearest_player()
	if is_dead or player == null:
		return
	if slow_timer > 0:
		slow_timer -= delta
		if slow_timer <= 0:
			current_speed = BASE_SPEED
			body.color = Color("#E74C3C")
	var direction = (player.global_position - global_position).normalized()
	global_position += direction * current_speed * delta
	_update_enemy_direction()
	damage_cooldown -= delta
	if global_position.distance_to(player.global_position) < 45 and damage_cooldown <= 0:
		player.take_damage(DAMAGE)
		damage_cooldown = 1.0

func flash():
	var tween = create_tween()
	body.color = Color.WHITE
	tween.tween_property(body, "color", Color("#E74C3C"), 0.12)
