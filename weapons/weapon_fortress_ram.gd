class_name WeaponFortressRam
extends WeaponBase

var ram_range = 142.0
var cone_degrees = 92.0

func _ready():
	super._ready()
	weapon_name = "Kale Sur Koşusu"
	tag = "ezici"
	category = "defense"
	damage = 38
	cooldown = 1.55

func attack():
	var enemies = EnemyRegistry.get_enemies()
	if enemies.is_empty():
		return
	var nearest: Node2D = null
	var best = 999999.0
	var ppos = player.global_position
	for enemy in enemies:
		var d = ppos.distance_to(enemy.global_position)
		if d < best:
			best = d
			nearest = enemy
	if nearest == null:
		return
	var forward = (nearest.global_position - ppos).normalized()
	if forward == Vector2.ZERO:
		forward = Vector2.RIGHT
	var half = deg_to_rad(cone_degrees * 0.5)
	var r = ram_range * player.get_area_multiplier()
	for enemy in enemies:
		var to_e = enemy.global_position - ppos
		var dist = to_e.length()
		if dist > r or dist < 1.0:
			continue
		var dir = to_e.normalized()
		if forward.angle_to(dir) > half:
			continue
		var final_damage = player.get_total_damage(damage)
		enemy.take_damage(final_damage, player)
		EventBus.on_damage_dealt.emit(player, enemy, final_damage)
		enemy.global_position += dir * 14.0

func on_upgrade():
	match level:
		2:
			damage = 46
			ram_range = 152.0
		3:
			cooldown = 1.38
		4:
			damage = 55
			ram_range = 165.0
		5:
			damage = 68
			cooldown = 1.2
			cone_degrees = 100.0

func get_description() -> String:
	return "Kale Sur Koşusu Lv" + str(level) + " | " + str(int(ram_range * player.get_area_multiplier())) + " menzil | " + str(damage) + " hasar (geniş koni)"
