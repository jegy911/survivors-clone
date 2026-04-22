class_name WeaponLaser
extends WeaponBase

const LASER_BEAM_TEX := preload("res://assets/projectiles/laser/laser_projectile.png")

var laser_range = 300.0

func _ready():
	super._ready()
	weapon_name = "Lazer"
	tag = "teknolojik"
	category = "attack"
	damage = 25
	cooldown = 1.8

func has_targets_for_attack() -> bool:
	return _any_enemy_within_distance(laser_range * player.get_area_multiplier())

func attack():
	var enemies = EnemyRegistry.get_enemies()
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
	var par: Node = player.get_parent()
	if par == null:
		return
	var vfx_a: float = player.get_player_vfx_opacity() if player else 1.0
	var tex_w: float = maxf(float(LASER_BEAM_TEX.get_width()), 1.0)
	var spr := Sprite2D.new()
	spr.texture = LASER_BEAM_TEX
	spr.centered = true
	spr.global_position = player.global_position + dir * (range_val * 0.5)
	spr.rotation = dir.angle()
	spr.scale = Vector2(range_val / tex_w, 0.16)
	spr.z_index = 55
	spr.z_as_relative = false
	spr.modulate = Color(1.0, 1.0, 1.0, 0.96 * vfx_a)
	par.add_child(spr)
	var mid: Vector2 = player.global_position + dir * (range_val * 0.52)
	CombatProjectileFx.spawn_hit_sparks(par, mid, player, Color("#FF8899"), 8, 32.0, 0.16)
	var tw := spr.create_tween()
	tw.tween_property(spr, "modulate:a", 0.0, 0.18)
	tw.tween_callback(spr.queue_free)

func on_upgrade():
	match level:
		2:
			damage = 30
			laser_range = 350.0
			cooldown = 1.6
		3:
			damage = 38
			laser_range = 400.0
		4:
			damage = 45
			laser_range = 450.0
			cooldown = 1.4
		5:
			damage = 55
			laser_range = 500.0
			cooldown = 1.2

func get_description() -> String:
	return tr("ui.upgrade_ui.stats.loadout_weapons.laser") % [
		level,
		int(laser_range * player.get_area_multiplier()),
		damage,
		snappedf(get_effective_cooldown(), 0.01),
	]
