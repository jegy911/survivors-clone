class_name WeaponDeathLaser
extends WeaponBase

var laser_range = 400.0

func _ready():
	super._ready()
	weapon_name = "Death Laser"
	tag = "teknolojik"
	category = "attack"
	damage = 40
	cooldown = 1.2
	max_level = 5

func attack():
	var enemies = EnemyRegistry.get_enemies()
	if enemies.is_empty():
		return
	
	enemies.sort_custom(func(a, b):
		return player.global_position.distance_to(a.global_position) < player.global_position.distance_to(b.global_position)
	)
	
	var target = enemies[0]
	var dir = (target.global_position - player.global_position).normalized()
	
	# Tüm düşmanlara kritik hasar
	for enemy in enemies:
		var to_enemy = (enemy.global_position - player.global_position)
		if to_enemy.length() > laser_range:
			continue
		var dot = dir.dot(to_enemy.normalized())
		if dot > 0.90:
			var final_damage = player.get_total_damage(int(damage * 1.5)) # ×1.5 kritik
			enemy.take_damage(final_damage, player)
			EventBus.on_damage_dealt.emit(player, enemy, final_damage)
	
	_spawn_laser_beam(dir)

func _spawn_laser_beam(dir: Vector2):
	var beam = ColorRect.new()
	beam.size = Vector2(laser_range, 6)
	beam.color = Color("#FF0000")
	beam.position = player.global_position
	beam.rotation = dir.angle()
	beam.modulate.a = player.get_player_vfx_opacity() if player else 1.0
	player.get_parent().add_child(beam)
	
	var tween = beam.create_tween()
	tween.tween_property(beam, "modulate:a", 0.0, 0.15)
	tween.tween_callback(beam.queue_free)

func on_upgrade():
	match level:
		2: damage = 48; laser_range = 450.0
		3: damage = 55; laser_range = 500.0; cooldown = 1.1
		4: damage = 65; laser_range = 550.0
		5: damage = 80; laser_range = 600.0; cooldown = 0.9

func get_description() -> String:
	return "Death Laser Lv" + str(level) + " | " + str(damage) + " hasar (KRİTİK)"
