class_name WeaponAura
extends WeaponBase

var radius = 80.0
var slow_factor = 0.5
var damage_number_scene = preload("res://effects/damage_number.tscn")

func _ready():
	super._ready()
	weapon_name = "Aura"
	category = "attack"
	damage = 15
	cooldown = 1.0

func attack():
	var effective_radius = radius * player.get_area_multiplier()
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if player.global_position.distance_to(enemy.global_position) <= effective_radius:
			var final_damage = player.get_total_damage(damage)
			enemy.take_damage(final_damage)
			player.on_damage_dealt(final_damage, enemy.global_position)
			
			if enemy.has_method("apply_slow"):
				enemy.apply_slow(slow_factor, 1.5)
			
			var popup = damage_number_scene.instantiate()
			player.get_parent().add_child(popup)
			popup.global_position = enemy.global_position + Vector2(0, -40)
			popup.show_damage(final_damage, Color("#F5A623"))

func on_upgrade():
	match level:
		2:
			radius = 100.0
			damage = 20
		3:
			cooldown = 0.8
			damage = 25
			slow_factor = 0.4
		4:
			radius = 130.0
			damage = 30
		5:
			radius = 160.0
			damage = 40
			cooldown = 0.6
			slow_factor = 0.3

func get_description() -> String:
	return "Aura Lv" + str(level) + " | " + str(int(radius * player.get_area_multiplier())) + " alan | " + str(damage) + " hasar"
