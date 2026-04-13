class_name WeaponAura
extends WeaponBase

var radius = 80.0
var slow_factor = 0.2
var hit_cooldowns = {}
const HIT_INTERVAL = 1.0

func _ready():
	super._ready()
	weapon_name = "Aura"
	tag = "patlayici"
	category = "attack"
	damage = 10
	cooldown = 1.2

func attack():
	var effective_radius = radius * player.get_area_multiplier()
	var enemies = EnemyRegistry.get_enemies()
	# Hit cooldown'ları temizle
	for key in hit_cooldowns.keys():
		hit_cooldowns[key] -= get_effective_cooldown()
		if hit_cooldowns[key] <= 0:
			hit_cooldowns.erase(key)
	for enemy in enemies:
		var enemy_id = enemy.get_instance_id()
		if hit_cooldowns.has(enemy_id):
			continue
		if player.global_position.distance_to(enemy.global_position) <= effective_radius:
			var final_damage = player.get_total_damage(damage)
			enemy.take_damage(final_damage, player)
			EventBus.on_damage_dealt.emit(player, enemy, final_damage)
			if enemy.has_method("apply_slow"):
				enemy.apply_slow(slow_factor, 1.5)
			hit_cooldowns[enemy_id] = HIT_INTERVAL
			

func on_upgrade():
	match level:
		2:
			radius = 100.0
			damage = 14
		3:
			cooldown = 1.0
			damage = 18
			slow_factor = 0.25
		4:
			radius = 120.0
			damage = 22
		5:
			radius = 140.0
			damage = 28
			cooldown = 0.8
			slow_factor = 0.3

func get_description() -> String:
	return "Aura Lv" + str(level) + " | " + str(int(radius * player.get_area_multiplier())) + " alan | " + str(damage) + " hasar"
