class_name ItemExplosion
extends PassiveItem

var explosion_radius = 0.0
var explosion_damage = 0
var exploded_positions = []
var damage_number_scene = preload("res://effects/damage_number.tscn")

func _ready():
	item_name = "Patlama"
	description = "Düşman ölünce alan hasarı"
	category = "attack"
	max_level = 5
	super._ready()

func apply():
	explosion_radius = 60.0 + (20.0 * level)
	explosion_damage = 10 * level

func on_enemy_killed(position: Vector2):
	for pos in exploded_positions:
		if pos.distance_to(position) < 10:
			return
	exploded_positions.append(position)
	call_deferred("_do_explosion", position)
	await get_tree().process_frame
	exploded_positions.erase(position)

func _do_explosion(position: Vector2):
	var effective_radius = explosion_radius * player.get_area_multiplier()
	var enemies = player.get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		if enemy.global_position.distance_to(position) <= effective_radius:
			if enemy.has_method("take_explosion_damage"):
				enemy.take_explosion_damage(explosion_damage)

func get_description() -> String:
	return "Patlama Lv" + str(level) + "\nÖlünce " + str(int(explosion_radius * player.get_area_multiplier())) + " alanda " + str(explosion_damage) + " hasar"
