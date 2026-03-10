class_name ItemLifesteal
extends PassiveItem

var steal_percent = 0.05

func _ready():
	item_name = "Can Çalma"
	description = "Verilen hasarın %5'i kadar can kazan (her vuruşta)"
	category = "vampire"
	max_level = 5
	super._ready()

func apply():
	steal_percent = 0.05 * level

func on_damage_dealt(_player: Node, _enemy: Node, damage: int):
	var heal_amount = int(damage * steal_percent)
	if heal_amount > 0 and player:
		player.heal(heal_amount)

func get_description() -> String:
	return "Can Çalma Lv" + str(level) + "\nHer vuruşta %" + str(int(steal_percent * 100)) + " hasar → HP"
