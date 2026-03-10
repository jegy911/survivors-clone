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

func on_damage_dealt(_player: Node, enemy: Node, _damage: int):
	if enemy.has_method("apply_poison"):
		var effective_duration = poison_duration * player.get_duration_multiplier()
		enemy.apply_poison(poison_damage, effective_duration)

func get_description() -> String:
	return "Zehir Lv" + str(level) + "\nVuruşta " + str(poison_damage) + " zehir/sn, " + str(snapped(poison_duration * player.get_duration_multiplier(), 0.1)) + "sn"
