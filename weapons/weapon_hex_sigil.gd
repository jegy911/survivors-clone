class_name WeaponHexSigil
extends WeaponBase

var radius = 88.0
var slow_factor = 0.42
var slow_duration = 2.0
var hit_cooldowns = {}
const HIT_INTERVAL = 0.85

func _ready():
	super._ready()
	weapon_name = "Altıgön Mühür"
	tag = "buyu"
	category = "utility"
	damage = 11
	cooldown = 1.05

func attack():
	var effective_radius = radius * player.get_area_multiplier()
	var enemies = EnemyRegistry.get_enemies()
	for key in hit_cooldowns.keys():
		hit_cooldowns[key] -= get_effective_cooldown()
		if hit_cooldowns[key] <= 0:
			hit_cooldowns.erase(key)
	for enemy in enemies:
		var enemy_id = enemy.get_instance_id()
		if hit_cooldowns.has(enemy_id):
			continue
		if player.global_position.distance_to(enemy.global_position) > effective_radius:
			continue
		var final_damage = player.get_total_damage(damage)
		enemy.take_damage(final_damage, player)
		EventBus.on_damage_dealt.emit(player, enemy, final_damage)
		if enemy.has_method("apply_slow"):
			enemy.apply_slow(slow_factor, slow_duration)
		hit_cooldowns[enemy_id] = HIT_INTERVAL

func on_upgrade():
	match level:
		2:
			radius = 100.0
			damage = 14
		3:
			cooldown = 0.92
			slow_duration = 2.3
		4:
			radius = 118.0
			damage = 17
			slow_factor = 0.38
		5:
			radius = 135.0
			damage = 21
			cooldown = 0.78
			slow_factor = 0.34

func get_description() -> String:
	return "Altıgön Mühür Lv" + str(level) + " | " + str(int(radius * player.get_area_multiplier())) + " alan | " + str(damage) + " hasar | yavaşlatır"
