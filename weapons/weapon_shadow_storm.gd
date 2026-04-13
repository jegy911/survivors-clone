class_name WeaponShadowStorm
extends WeaponBase

var orbit_radius = 80.0
var orbit_angle = 0.0
var lightning_cooldown = 0.0

func _ready():
	super._ready()
	weapon_name = "Gölge Fırtınası"
	category = "attack"
	tag = "patlayici"
	damage = 25
	cooldown = 0.8
	max_level = 5

func attack():
	orbit_angle += 0.4
	var orbit_pos = player.global_position + Vector2(cos(orbit_angle), sin(orbit_angle)) * orbit_radius * player.get_area_multiplier()
	
	var enemies = EnemyRegistry.get_enemies()
	for enemy in enemies:
		if enemy.global_position.distance_to(orbit_pos) < 40:
			var final_damage = player.get_total_damage(damage)
			enemy.take_damage(final_damage, player)
			EventBus.on_damage_dealt.emit(player, enemy, final_damage)
			# Yıldırım zinciri tetikle
			_chain_lightning(enemy)
	
	# Görsel
	var orb = ColorRect.new()
	orb.size = Vector2(14, 14)
	orb.color = Color("#8E44AD")
	orb.global_position = orbit_pos - Vector2(7, 7)
	orb.modulate.a = player.get_player_vfx_opacity() if player else 1.0
	player.get_parent().add_child(orb)
	var tween = orb.create_tween()
	tween.tween_property(orb, "modulate:a", 0.0, 0.3)
	tween.tween_callback(orb.queue_free)

func _chain_lightning(start_enemy: Node):
	var enemies = EnemyRegistry.get_enemies()
	var hit = [start_enemy]
	var current = start_enemy
	for i in 3:
		var next = null
		var best = 200.0
		for e in enemies:
			if e in hit:
				continue
			var d = current.global_position.distance_to(e.global_position)
			if d < best:
				best = d
				next = e
		if next == null:
			break
		var final_damage = player.get_total_damage(int(damage * 0.4))
		next.take_damage(final_damage)
		EventBus.on_damage_dealt.emit(player, next, final_damage)
		hit.append(next)
		current = next

func on_upgrade():
	match level:
		2: damage = 30; orbit_radius = 90
		3: damage = 36; cooldown = 0.7
		4: damage = 44; orbit_radius = 110
		5: damage = 55; cooldown = 0.5; orbit_radius = 130

func get_description() -> String:
	return "Gölge Fırtınası Lv" + str(level) + " | " + str(damage) + " hasar | zincir"
