class_name PassiveItem
extends Node

var item_name = "Pasif Eşya"
var description = ""
var level = 1
var max_level = 5
var category = "attack"

var player = null

func _ready():
	player = get_parent()
	if player and "category_counts" in player:
		player.category_counts[category] = player.category_counts.get(category, 0) + 1
	apply()
	if player and player.has_method("recalculate_category_bonuses"):
		player.recalculate_category_bonuses()

func apply():
	pass

func upgrade():
	if level >= max_level:
		return false
	level += 1
	apply()
	if player and player.has_method("recalculate_category_bonuses"):
		player.recalculate_category_bonuses()
	return true

func get_description() -> String:
	return item_name + " Lv" + str(level)
