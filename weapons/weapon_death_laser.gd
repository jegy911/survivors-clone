class_name WeaponDeathLaser
extends WeaponBase

const DEATH_LASER_BEAM_TEX := preload("res://assets/projectiles/death_laser/death_laser_projectile.png")

var laser_range = 400.0

func _ready():
	super._ready()
	weapon_name = "Death Laser"
	tag = "teknolojik"
	category = "attack"
	damage = 40
	cooldown = 1.2
	max_level = 5

func has_targets_for_attack() -> bool:
	return _any_enemy_within_distance(laser_range * player.get_area_multiplier())

func attack():
	var enemies = EnemyRegistry.get_enemies()
	if enemies.is_empty():
		return

	var eff_r: float = laser_range * player.get_area_multiplier()

	enemies.sort_custom(func(a, b):
		return player.global_position.distance_to(a.global_position) < player.global_position.distance_to(b.global_position)
	)

	var target = enemies[0]
	if player.global_position.distance_to(target.global_position) > eff_r:
		return
	var dir: Vector2 = (target.global_position - player.global_position).normalized()

	var hit_any := false
	for enemy in enemies:
		var to_enemy: Vector2 = enemy.global_position - player.global_position
		if to_enemy.length() > eff_r:
			continue
		var dot: float = dir.dot(to_enemy.normalized())
		if dot > 0.90:
			var final_damage: int = player.get_total_damage(int(damage * 1.5), enemy)
			enemy.take_damage(final_damage, player)
			EventBus.on_damage_dealt.emit(player, enemy, final_damage)
			hit_any = true

	if hit_any:
		_spawn_laser_beam(dir, eff_r)

func _spawn_laser_beam(dir: Vector2, range_val: float):
	var par: Node = player.get_parent()
	if par == null:
		return
	var vfx_a: float = player.get_player_vfx_opacity() if player else 1.0
	var tex_w: float = maxf(float(DEATH_LASER_BEAM_TEX.get_width()), 1.0)
	var spr := Sprite2D.new()
	spr.texture = DEATH_LASER_BEAM_TEX
	spr.centered = true
	spr.global_position = player.global_position + dir * (range_val * 0.5)
	spr.rotation = dir.angle()
	spr.scale = Vector2(range_val / tex_w, 0.2)
	spr.z_index = 56
	spr.z_as_relative = false
	spr.modulate = Color(1.0, 1.0, 1.0, 0.98 * vfx_a)
	par.add_child(spr)
	var tw := spr.create_tween()
	tw.tween_property(spr, "modulate:a", 0.0, 0.15)
	tw.tween_callback(spr.queue_free)

func on_upgrade():
	match level:
		2: damage = 48; laser_range = 450.0
		3: damage = 55; laser_range = 500.0; cooldown = 1.1
		4: damage = 65; laser_range = 550.0
		5: damage = 80; laser_range = 600.0; cooldown = 0.9

func get_description() -> String:
	return tr("ui.upgrade_ui.stats.death_laser_desc") % [
		level,
		damage,
		int(laser_range * player.get_area_multiplier()),
		snappedf(get_effective_cooldown(), 0.01),
	]
