class_name ItemFieldLens
extends PassiveItem

## `player.get_area_multiplier()` içinde okunur — tüm alan ölçekli silahlara katkı.
var area_bonus_pct: float = 0.0

func _ready() -> void:
	item_name = "Alan Merceği"
	description = "Odak merceği — alan etkilerini büyütür"
	category = "utility"
	max_level = 5
	super._ready()

func apply() -> void:
	area_bonus_pct = 0.025 + float(level - 1) * 0.02

func get_area_bonus_pct() -> float:
	return area_bonus_pct

func get_description() -> String:
	return tr("ui.upgrade_ui.stats.loadout_items.field_lens") % [level, int(round(area_bonus_pct * 100.0))]
