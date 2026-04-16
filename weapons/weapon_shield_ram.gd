class_name WeaponShieldRam
extends WeaponBase

var ram_range = 108.0
var cone_degrees = 72.0

func _ready():
	super._ready()
	weapon_name = "Kalkan Hamlesi"
	tag = "ezici"
	category = "defense"
	damage = 20
	cooldown = 2.2

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
		enemy.global_position += dir * 10.0

func on_upgrade():
	match level:
		2:
			damage = 25
			ram_range = 118.0
		3:
			cooldown = 1.9
			cone_degrees = 80.0
		4:
			damage = 32
			ram_range = 128.0
		5:
			damage = 40
			cooldown = 1.6
			cone_degrees = 88.0

func get_description() -> String:
	return tr("ui.upgrade_ui.stats.loadout_weapons.shield_ram") % [
		level,
		int(ram_range * player.get_area_multiplier()),
		int(cone_degrees),
		damage,
		snappedf(get_effective_cooldown(), 0.01),
	]
