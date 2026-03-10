class_name WeaponChain
extends WeaponBase

var chain_count = 3
var chain_range = 150.0
var bounce_multiplier = 1.2

func _ready():
	super._ready()
	weapon_name = "Zincir"
	category = "attack"
	damage = 20
	cooldown = 1.5

func attack():
	var enemies = get_tree().get_nodes_in_group("enemies")
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
			chain_count = 4
			damage = 25
		3:
			chain_range = 200.0
			damage = 30
			bounce_multiplier = 1.3
		4:
			chain_count = 5
			damage = 35
		5:
			chain_count = 7
			chain_range = 250.0
			damage = 50
			cooldown = 1.0
			bounce_multiplier = 1.4

func get_description() -> String:
	return "Zincir Lv" + str(level) + " | " + str(chain_count + get_effective_multi_attack()) + " zincir | " + str(damage) + " hasar"
