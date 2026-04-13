class_name ItemGlyphCharm
extends PassiveItem

## `player.gd` take_damage içinde zırha eklenir.
var ward_value = 0.0

func _ready():
	item_name = "Rün Tılsımı"
	description = "İşlenmiş rünler alınan hasarı azaltır"
	category = "utility"
	max_level = 5
	super._ready()

func apply():
	ward_value = 0.5 * level

func get_description() -> String:
	return "Rün Tılsımı Lv" + str(level) + " | -" + str(snappedf(ward_value, 0.1)) + " hasar"
