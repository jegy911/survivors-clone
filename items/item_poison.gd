class_name ItemPoison
extends PassiveItem

var poison_damage = 3
var poison_duration = 3.0

func _ready():
	item_name = "Zehir"
	description = "Vuruşta zehir uygular"
	category = "attack"
	max_level = 5
	super._ready()

func apply():
	poison_damage = 3 + (level - 1) * 2
	poison_duration = 3.0 + (level - 1) * 0.5

func on_damage_dealt(damage: int):
	var enemies = player.get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy.has_method("apply_poison"):
			var dist = player.global_position.distance_to(enemy.global_position)
			if dist < 50:
				var effective_duration = poison_duration * player.get_duration_multiplier()
				enemy.apply_poison(poison_damage, effective_duration)

func get_description() -> String:
	return "Zehir Lv" + str(level) + "\nVuruşta " + str(poison_damage) + " zehir/sn, " + str(snapped(poison_duration * player.get_duration_multiplier(), 0.1)) + "sn"
