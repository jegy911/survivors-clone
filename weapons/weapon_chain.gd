class_name WeaponChain
extends WeaponBase

var chain_count = 2
var chain_range = 150.0
var bounce_multiplier = 1.1
## Sıçrama arası bekleme (sn); zincir çizgisini görmek için.
@export var chain_step_delay_sec: float = 0.15

var _chain_running: bool = false


func _process(delta: float) -> void:
	if _chain_running:
		return
	super._process(delta)


func _ready():
	super._ready()
	weapon_name = "Zincir"
	tag = "kesici"
	category = "attack"
	damage = 15
	cooldown = 1.6

func attack() -> void:
	if _chain_running:
		return
	var enemies = EnemyRegistry.get_enemies()
	if enemies.is_empty():
		return
	_chain_running = true
	_run_chain_sequence(enemies)


func _run_chain_sequence(enemies: Array) -> void:
	enemies.sort_custom(func(a, b):
		return player.global_position.distance_to(a.global_position) < player.global_position.distance_to(b.global_position)
	)

	var hit_enemies: Array = []
	var current_pos: Vector2 = player.global_position
	var current_damage: float = float(damage)
	var effective_chain: int = chain_count + get_effective_multi_attack()
	var effective_range: float = chain_range * player.get_area_multiplier()
	var max_hits: int = mini(effective_chain, enemies.size())

	for i in max_hits:
		var nearest = null
		var nearest_dist: float = 999999.0
		for enemy in enemies:
			if enemy in hit_enemies:
				continue
			var dist: float = current_pos.distance_to(enemy.global_position)
			if dist < nearest_dist and dist < effective_range:
				nearest_dist = dist
				nearest = enemy
		if nearest == null:
			break

		var final_damage: int = player.get_total_damage(int(current_damage))
		nearest.take_damage(final_damage)
		EventBus.on_damage_dealt.emit(player, nearest, final_damage)
		hit_enemies.append(nearest)
		var green_intensity: float = 0.45 + (float(i) / float(maxi(effective_chain, 1))) * 0.55
		## Tam opak segment; VFX biraz daha parlak (saydam hissi azalır).
		var seg_color := Color(0.28, green_intensity, 0.48, 1.0)
		CombatProjectileFx.spawn_chain_segment(
			player.get_parent(), current_pos, nearest.global_position, player, seg_color
		)
		current_pos = nearest.global_position
		current_damage *= bounce_multiplier

		if i < max_hits - 1 and chain_step_delay_sec > 0.0:
			await get_tree().create_timer(chain_step_delay_sec).timeout

	_chain_running = false

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
	return tr("ui.upgrade_ui.stats.loadout_weapons.chain") % [
		level,
		chain_count + get_effective_multi_attack(),
		damage,
		int(chain_range * player.get_area_multiplier()),
		snappedf(get_effective_cooldown(), 0.01),
	]
