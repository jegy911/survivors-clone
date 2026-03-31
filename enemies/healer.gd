extends EnemyBase

const HEAL_RADIUS = 200.0
const HEAL_AMOUNT = 15
const PREFERRED_DISTANCE = 300.0
var heal_cooldown = 0.0

func _ready():
	super._ready()
	BASE_SPEED = 38.0
	DAMAGE = 8
	XP_VALUE = 15
	XP_DROP_CHANCE = 0.80
	hp = 50
	max_hp = 50
	current_speed = BASE_SPEED
	particle_color = Color("#00FF7F")
	body.color = Color("#00FF7F")

func _process(delta):
	player = _get_nearest_player()
	if is_dead or player == null:
		return
	
	heal_cooldown -= delta
	damage_cooldown -= delta

	if heal_cooldown <= 0:
		_heal_nearby_enemies()
		heal_cooldown = 3.0

	# Preferred distance — arkada dur
	var dist = global_position.distance_to(player.global_position)
	var direction = (player.global_position - global_position).normalized()
	if dist < PREFERRED_DISTANCE - 50:
		# Çok yakın — geri çekil
		global_position += -direction * current_speed * delta
	elif dist > PREFERRED_DISTANCE + 50:
		# Çok uzak — yaklaş
		global_position += direction * current_speed * delta

	if damage_cooldown <= 0 and dist < 40:
		player.take_damage(DAMAGE)
		damage_cooldown = 1.0

	_update_enemy_direction()

func _heal_nearby_enemies():
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy == self:
			continue
		if global_position.distance_to(enemy.global_position) < HEAL_RADIUS:
			enemy.hp = min(enemy.hp + HEAL_AMOUNT, enemy.max_hp)
			if enemy.has_method("_update_hp_bar"):
				enemy._update_hp_bar()
			if SaveManager.settings.get("show_vfx", true):
				var fx = ColorRect.new()
				fx.size = Vector2(10, 10)
				fx.color = Color("#00FF7F")
				fx.position = enemy.global_position - Vector2(5, 5)
				get_parent().add_child(fx)
				var tween = fx.create_tween()
				tween.tween_property(fx, "modulate:a", 0.0, 0.3)
				tween.tween_callback(fx.queue_free)

func flash():
	var tween = create_tween()
	body.color = Color.WHITE
	tween.tween_property(body, "color", Color("#00FF7F"), 0.12)
