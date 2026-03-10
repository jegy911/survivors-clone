extends EnemyBase

const HEAL_RADIUS = 150.0
const HEAL_AMOUNT = 5
var heal_cooldown = 0.0

func _ready():
	super._ready()
	BASE_SPEED = 38.0
	DAMAGE = 8
	XP_VALUE = 15
	XP_DROP_CHANCE = 0.80
	hp = 35
	max_hp = 35
	current_speed = BASE_SPEED
	particle_color = Color("#00FF7F")
	body.color = Color("#00FF7F")

func _process(delta):
	if is_dead or player == null:
		return
	damage_cooldown -= delta
	heal_cooldown -= delta
	if heal_cooldown <= 0:
		_heal_nearby_enemies()
		heal_cooldown = 2.0
	var direction = (player.global_position - global_position).normalized()
	global_position += direction * BASE_SPEED * delta
	if damage_cooldown <= 0 and global_position.distance_to(player.global_position) < 40:
		player.take_damage(DAMAGE)
		damage_cooldown = 1.0

func _heal_nearby_enemies():
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy == self:
			continue
		if global_position.distance_to(enemy.global_position) < HEAL_RADIUS:
			if enemy.has_method("take_damage"):
				enemy.hp = min(enemy.hp + HEAL_AMOUNT, enemy.max_hp)
				if enemy.has_method("update_hp_bar"):
					enemy.update_hp_bar()
				if SaveManager.settings.get("show_vfx", true):
					var fx = ColorRect.new()
					fx.size = Vector2(10, 10)
					fx.color = Color("#00FF7F")
					fx.position = enemy.global_position - Vector2(5, 5)
					get_parent().add_child(fx)
					var tween = fx.create_tween()
					tween.tween_property(fx, "modulate:a", 0.0, 0.3)
					tween.tween_callback(fx.queue_free)

func heal_hp(amount: int):
	hp = min(hp + amount, max_hp)

func flash():
	var tween = create_tween()
	body.color = Color.WHITE
	tween.tween_property(body, "color", Color("#00FF7F"), 0.12)
