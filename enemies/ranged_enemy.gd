extends EnemyBase
const DISABLED = true

const PREFERRED_DISTANCE = 250.0

func _ready():
	super._ready()
	BASE_SPEED = 42.0
	DAMAGE = 12
	XP_VALUE = 12
	XP_DROP_CHANCE = 0.75
	hp = 40
	max_hp = 40
	current_speed = BASE_SPEED
	particle_color = Color("#E67E22")
	body.color = Color("#E67E22")

func _process(delta):
	player = _get_nearest_player()
	if is_dead or player == null:
		return
	if is_dead or player == null:
		return
	if slow_timer > 0:
		slow_timer -= delta
		if slow_timer <= 0:
			current_speed = BASE_SPEED
			body.color = Color("#E67E22")
	var dist = global_position.distance_to(player.global_position)
	var direction = (player.global_position - global_position).normalized()
	if dist < PREFERRED_DISTANCE - 50:
		global_position += -direction * current_speed * delta
	elif dist > PREFERRED_DISTANCE + 50:
		global_position += direction * current_speed * delta
	damage_cooldown -= delta
	if damage_cooldown <= 0 and dist < 400:
		shoot()
		damage_cooldown = 1.8

func shoot():
	var bullet = ObjectPool.get_object("res://projectiles/enemy_bullet.tscn")
	bullet.global_position = global_position
	var dir = (player.global_position - global_position).normalized()
	bullet.init(dir, DAMAGE)

func flash():
	var tween = create_tween()
	body.color = Color.WHITE
	tween.tween_property(body, "color", Color("#E67E22"), 0.12)
