extends EnemyBase

var shield_hp = 40
var shield_broken = false

func _ready():
	super._ready()
	BASE_SPEED = 45.0
	DAMAGE = 20
	XP_VALUE = 17
	XP_DROP_CHANCE = 0.80
	hp = 60
	max_hp = 60
	current_speed = BASE_SPEED
	particle_color = Color("#FF4500")
	body.color = Color("#4169E1")

func _process(delta):
	player = _get_nearest_player()
	if is_dead or player == null:
		return
	damage_cooldown -= delta
	var direction = (player.global_position - global_position).normalized()
	global_position += direction * BASE_SPEED * delta
	if damage_cooldown <= 0 and global_position.distance_to(player.global_position) < 45:
		player.take_damage(DAMAGE)
		damage_cooldown = 1.2

func take_damage(amount: int):
	if is_dead:
		return
	if not shield_broken:
		shield_hp -= amount
		if SaveManager.settings.get("show_damage_numbers", true):
			var popup = ObjectPool.get_object("res://effects/damage_number.tscn")
			popup.global_position = global_position + Vector2(0, -50)
			popup.show_damage(amount, Color("#4169E1"))
		AudioManager.play_hit()
		if shield_hp <= 0:
			_break_shield()
		return
	super.take_damage(amount)

func _break_shield():
	shield_broken = true
	body.color = Color("#FF4500")
	if SaveManager.settings.get("show_vfx", true):
		for i in 8:
			var shard = ColorRect.new()
			shard.size = Vector2(8, 8)
			shard.color = Color("#4169E1")
			shard.position = global_position
			get_parent().add_child(shard)
			var angle = (float(i) / 8.0) * TAU
			var target = global_position + Vector2(cos(angle), sin(angle)) * randf_range(30, 70)
			var tween = shard.create_tween()
			tween.set_parallel(true)
			tween.tween_property(shard, "position", target, 0.3)
			tween.tween_property(shard, "modulate:a", 0.0, 0.3)
			tween.set_parallel(false)
			tween.tween_callback(shard.queue_free)

func flash():
	var tween = create_tween()
	body.color = Color.WHITE
	tween.tween_property(body, "color", Color("#FF4500"), 0.12)
