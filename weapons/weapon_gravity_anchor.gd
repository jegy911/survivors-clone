class_name WeaponGravityAnchor
extends WeaponBase

var radius = 118.0
var pull_strength = 11.0
var hit_cooldowns = {}
const HIT_INTERVAL = 0.95

func _ready():
	super._ready()
	weapon_name = "Çekim Çapası"
	tag = "buyu"
	category = "utility"
	damage = 9
	cooldown = 1.15

func attack():
	var effective_radius = radius * player.get_area_multiplier()
	var enemies = EnemyRegistry.get_enemies()
	for key in hit_cooldowns.keys():
		hit_cooldowns[key] -= get_effective_cooldown()
		if hit_cooldowns[key] <= 0:
			hit_cooldowns.erase(key)
	var ppos = player.global_position
	for enemy in enemies:
		var dist = ppos.distance_to(enemy.global_position)
		if dist > effective_radius or dist < 12.0:
			continue
		var dir = (ppos - enemy.global_position).normalized()
		enemy.global_position += dir * pull_strength
		var enemy_id = enemy.get_instance_id()
		if hit_cooldowns.has(enemy_id):
			continue
		var final_damage = player.get_total_damage(damage)
		enemy.take_damage(final_damage, player)
		EventBus.on_damage_dealt.emit(player, enemy, final_damage)
		hit_cooldowns[enemy_id] = HIT_INTERVAL

func on_upgrade():
	match level:
		2:
			pull_strength = 13.0
			damage = 11
		3:
			radius = 132.0
			cooldown = 1.0
		4:
			pull_strength = 16.0
			damage = 14
		5:
			radius = 148.0
			pull_strength = 19.0
			damage = 17
			cooldown = 0.88

func get_description() -> String:
	return "Çekim Çapası Lv" + str(level) + " | " + str(int(radius * player.get_area_multiplier())) + " menzil | çeker + " + str(damage) + " hasar"
