class_name WeaponChain
extends WeaponBase

var chain_count = 2
var chain_range = 150.0
var bounce_multiplier = 1.1

func _ready():
	super._ready()
	weapon_name = "Zincir"
	tag = "kesici"
	category = "attack"
	damage = 15
	cooldown = 1.6

func attack():
	var enemies = EnemyRegistry.get_enemies()
	if enemies.is_empty():
		return
	
	enemies.sort_custom(func(a, b):
		return player.global_position.distance_to(a.global_position) < player.global_position.distance_to(b.global_position)
	)
	
	var hit_enemies = []
	var current_pos = player.global_position
	var current_damage = float(damage)
	var effective_chain = chain_count + get_effective_multi_attack()
	var effective_range = chain_range * player.get_area_multiplier()
	
	for i in min(effective_chain, enemies.size()):
		var nearest = null
		var nearest_dist = 999999.0
		for enemy in enemies:
			if enemy in hit_enemies:
				continue
			var dist = current_pos.distance_to(enemy.global_position)
			if dist < nearest_dist and dist < effective_range:
				nearest_dist = dist
				nearest = enemy
		if nearest == null:
			break
		
		var final_damage = player.get_total_damage(int(current_damage))
		nearest.take_damage(final_damage)
		EventBus.on_damage_dealt.emit(player, nearest, final_damage)
		hit_enemies.append(nearest)
		current_pos = nearest.global_position
		
		var green_intensity = 0.4 + (float(i) / float(effective_chain)) * 0.6
		var color = Color(0.0, green_intensity, 0.0)
		
		
		current_damage *= bounce_multiplier

func on_upgrade():
	match level:
		2:
			chain_count = 3
			damage = 18
		3:
			chain_range = 180.0
			damage = 22
			cooldown = 1.5
			bounce_multiplier = 1.15
		4:
			chain_count = 4
			damage = 26
		5:
			chain_count = 5
			damage = 32
			chain_range = 220.0
			cooldown = 1.2
			bounce_multiplier = 1.2

func get_description() -> String:
	return "Zincir Lv" + str(level) + " | " + str(chain_count + get_effective_multi_attack()) + " zincir | " + str(damage) + " hasar"
