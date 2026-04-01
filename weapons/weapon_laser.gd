class_name WeaponLaser
extends WeaponBase

var laser_range = 600.0

func _ready():
	super._ready()
	weapon_name = "Lazer"
	tag = "teknolojik"
	category = "attack"
	damage = 30
	cooldown = 1.5

func attack():
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return
	enemies.sort_custom(func(a, b):
		return player.global_position.distance_to(a.global_position) < player.global_position.distance_to(b.global_position)
	)
	var target = enemies[0]
	var dir = (target.global_position - player.global_position).normalized()
	var effective_range = laser_range * player.get_area_multiplier()

	var directions = [dir]
	var extra = get_effective_multi_attack()
	for i in extra:
		var angle_offset = (float(i + 1) * 15.0) * (PI / 180.0)
		directions.append(dir.rotated(angle_offset))
		directions.append(dir.rotated(-angle_offset))

	for d in directions:
		_spawn_laser_beam(d, effective_range)

	# Her düşmana sadece bir kez hasar ver
	var hit_enemies = []
	for d in directions:
		for enemy in enemies:
			if enemy in hit_enemies:
				continue
			var to_enemy = enemy.global_position - player.global_position
			var dist = to_enemy.length()
			if dist > effective_range:
				continue
			var dot = to_enemy.normalized().dot(d)
			if dot > 0.92:
				var final_damage = player.get_total_damage(damage)
				enemy.take_damage(final_damage, player)
				EventBus.on_damage_dealt.emit(player, enemy, final_damage)
				hit_enemies.append(enemy)
				
				

func _spawn_laser_beam(dir: Vector2, range_val: float):
	var beam = ColorRect.new()
	beam.size = Vector2(range_val, 4)
	beam.color = Color("#FF0000")
	beam.position = player.global_position
	beam.rotation = dir.angle()
	player.get_parent().add_child(beam)
	
	var tween = beam.create_tween()
	tween.tween_property(beam, "modulate:a", 0.0, 0.15)
	tween.tween_callback(beam.queue_free)

func on_upgrade():
	match level:
		2:
			damage = 38
			cooldown = 1.4
		3:
			laser_range = 700.0
			damage = 45
		4:
			damage = 55
			cooldown = 1.2
		5:
			laser_range = 800.0
			damage = 70
			cooldown = 1.0

func get_description() -> String:
	return "Lazer Lv" + str(level) + " | " + str(int(laser_range * player.get_area_multiplier())) + " menzil | " + str(damage) + " hasar"
