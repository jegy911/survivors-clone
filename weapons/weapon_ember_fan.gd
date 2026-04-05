class_name WeaponEmberFan
extends WeaponBase

var blade_count = 5
var spread_degrees = 40.0
var fire_range = 200.0
var shard_speed = 300.0
var shard_lifetime = 0.24
var pierce = 1

func _ready():
	super._ready()
	weapon_name = "Kor Yelpazesi"
	tag = "kesici"
	category = "attack"
	damage = 12
	cooldown = 1.05
	max_level = 5

func attack():
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return
	var nearest = null
	var best = 999999.0
	for enemy in enemies:
		var dist = player.global_position.distance_to(enemy.global_position)
		if dist <= fire_range and dist < best:
			best = dist
			nearest = enemy
	if nearest == null:
		return
	var base_dir = (nearest.global_position - player.global_position).normalized()
	AudioManager.play_shoot()
	var total_blades = blade_count + get_effective_multi_attack()
	var angles: Array = []
	if total_blades <= 1:
		angles = [0.0]
	else:
		var half = deg_to_rad(spread_degrees)
		var span = half * 2.0
		for i in total_blades:
			angles.append(-half + span * (float(i) / float(total_blades - 1)))
	var ember_tint = Color(1.0, 0.55, 0.12, 1.0)
	for ang in angles:
		var dir = base_dir.rotated(ang)
		var shard = ObjectPool.get_object("res://projectiles/fan_blade_shard.tscn")
		shard.global_position = player.global_position
		shard.init(
			dir,
			player.get_total_damage(damage),
			player,
			pierce,
			ember_tint,
			shard_speed,
			shard_lifetime
		)

func on_upgrade():
	match level:
		2:
			damage = 15
			spread_degrees = 44.0
		3:
			blade_count = 6
			cooldown = 0.92
		4:
			damage = 19
			fire_range = 215.0
		5:
			blade_count = 7
			damage = 24
			pierce = 2
			cooldown = 0.82

func get_description() -> String:
	return "Kor Yelpazesi Lv" + str(level) + " | x" + str(blade_count + get_effective_multi_attack()) + " | " + str(damage) + " hasar | delici"
