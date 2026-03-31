class_name WeaponFrostNova
extends WeaponBase

var nova_radius = 120.0
var reflect_damage = 0.3

func _ready():
	super._ready()
	weapon_name = "Buz Novas"
	category = "defense"
	tag = "buyu"
	damage = 25
	cooldown = 2.0
	max_level = 5

func attack():
	var effective_radius = nova_radius * player.get_area_multiplier()
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy.global_position.distance_to(player.global_position) < effective_radius:
			var final_damage = player.get_total_damage(damage)
			enemy.take_damage(final_damage, player)
			EventBus.on_damage_dealt.emit(player, enemy, final_damage)
			if enemy.has_method("apply_slow"):
				enemy.apply_slow(0.15, 2.5)
	
	# Alan görsel
	var nova = ColorRect.new()
	nova.size = Vector2(effective_radius * 2, effective_radius * 2)
	nova.color = Color("#00BFFF")
	nova.modulate.a = 0.35
	nova.global_position = player.global_position - Vector2(effective_radius, effective_radius)
	player.get_parent().add_child(nova)
	var tween = nova.create_tween()
	tween.tween_property(nova, "modulate:a", 0.0, 0.5)
	tween.tween_callback(nova.queue_free)

func on_upgrade():
	match level:
		2: damage = 32; nova_radius = 135
		3: cooldown = 1.8; damage = 40
		4: nova_radius = 150; damage = 50; reflect_damage = 0.4
		5: damage = 65; cooldown = 1.5; nova_radius = 175

func get_description() -> String:
	return "Buz Novas Lv" + str(level) + " | " + str(int(nova_radius * player.get_area_multiplier())) + " alan | dondurma"
