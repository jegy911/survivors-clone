class_name WeaponFrostNova
extends WeaponBase

const NOVA_RING_TEXTURE := preload("res://assets/projectiles/frost_nova/nova_ring.png")

var nova_radius = 120.0
var reflect_damage = 0.2

func _ready():
	super._ready()
	weapon_name = "Frost Nova"
	category = "defense"
	tag = "buyu"
	damage = 20
	cooldown = 2.2
	max_level = 5

func has_targets_for_attack() -> bool:
	var eff: float = nova_radius * player.get_area_multiplier()
	var ppos: Vector2 = player.global_position
	for e in EnemyRegistry.get_enemies():
		if is_instance_valid(e) and e is Node2D:
			if ppos.distance_to((e as Node2D).global_position) < eff:
				return true
	return false

func attack():
	var effective_radius = nova_radius * player.get_area_multiplier()
	var enemies = EnemyRegistry.get_enemies()
	for enemy in enemies:
		if enemy.global_position.distance_to(player.global_position) < effective_radius:
			var final_damage = player.get_total_damage(damage, enemy)
			enemy.take_damage(final_damage, player)
			EventBus.on_damage_dealt.emit(player, enemy, final_damage)
			if enemy.has_method("apply_slow"):
				enemy.apply_slow(0.15, 2.5)
	
	# Alan görsel — dokulu halka
	var vfx_a: float = player.get_player_vfx_opacity() if player else 1.0
	var spr := Sprite2D.new()
	spr.texture = NOVA_RING_TEXTURE
	spr.centered = true
	spr.global_position = player.global_position
	var d: float = maxf(float(NOVA_RING_TEXTURE.get_width()), 1.0)
	var s: float = (effective_radius * 2.0) / d
	spr.scale = Vector2(s, s)
	spr.modulate = Color(1, 1, 1, 0.55 * vfx_a)
	var nova: CanvasItem = spr
	player.get_parent().add_child(nova)
	var tween = nova.create_tween()
	tween.tween_property(nova, "modulate:a", 0.0, 0.5)
	tween.tween_callback(nova.queue_free)

func on_upgrade():
	match level:
		2: damage = 26; nova_radius = 135
		3: damage = 32; cooldown = 2.0
		4: damage = 40; nova_radius = 150; reflect_damage = 0.3
		5: damage = 52; cooldown = 1.7; nova_radius = 175

func get_description() -> String:
	return tr("ui.upgrade_ui.stats.loadout_weapons.frost_nova") % [
		level,
		int(nova_radius * player.get_area_multiplier()),
		damage,
		snappedf(get_effective_cooldown(), 0.01),
	]
