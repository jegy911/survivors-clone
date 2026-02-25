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
	apply()

func apply():
	pass

func upgrade():
	if level >= max_level:
		return false
	level += 1
	apply()
	return true

func get_description() -> String:
	return item_name + " Lv" + str(level)
