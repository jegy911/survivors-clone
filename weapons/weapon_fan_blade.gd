class_name WeaponFanBlade
extends WeaponBase

var blade_count = 3
var spread_degrees = 28.0
var fire_range = 175.0
var shard_speed = 240.0
var shard_lifetime = 0.18

func _ready():
	super._ready()
	weapon_name = "Yelpaze Bıçak"
	tag = "kesici"
	category = "attack"
	damage = 7
	cooldown = 1.35

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
	var tint = Color(0.92, 0.4, 0.1, 1.0)
	for ang in angles:
		var dir = base_dir.rotated(ang)
		var shard = ObjectPool.get_object("res://projectiles/fan_blade_shard.tscn")
		shard.global_position = player.global_position
		shard.init(dir, player.get_total_damage(damage), player, 0, tint, shard_speed, shard_lifetime)

func on_upgrade():
	match level:
		2:
			damage = 9
			spread_degrees = 32.0
			fire_range = 182.0
		3:
			blade_count = 4
			cooldown = 1.15
		4:
			damage = 12
			spread_degrees = 36.0
			fire_range = 190.0
		5:
			blade_count = 5
			damage = 15
			cooldown = 0.95
			shard_speed = 265.0
			shard_lifetime = 0.2

func get_description() -> String:
	return "Yelpaze Bıçak Lv" + str(level) + " | x" + str(blade_count + get_effective_multi_attack()) + " | " + str(damage) + " hasar | yakın menzil"
