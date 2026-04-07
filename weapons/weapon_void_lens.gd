class_name WeaponVoidLens
extends WeaponBase

var radius = 158.0
var pull_strength = 17.0
var hit_cooldowns = {}
const HIT_INTERVAL = 0.78

func _ready():
	super._ready()
	weapon_name = "Uçurum Merceği"
	tag = "buyu"
	category = "utility"
	damage = 15
	cooldown = 0.95

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
		if dist > effective_radius or dist < 10.0:
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
			damage = 19
			pull_strength = 20.0
		3:
			radius = 172.0
			cooldown = 0.82
		4:
			damage = 24
			pull_strength = 23.0
		5:
			damage = 30
			radius = 188.0
			cooldown = 0.72

func get_description() -> String:
	return "Uçurum Merceği Lv" + str(level) + " | " + str(int(radius * player.get_area_multiplier())) + " menzil | güçlü çekim + " + str(damage) + " hasar"
