class_name CategoryBonus
extends RefCounted

static func get_bonus(category: String, count: int) -> Dictionary:
	var bonus = {"damage": 0, "speed": 0, "hp": 0, "crit": 0.0, "xp": 0.0}
	
	match category:
		"attack":
			if count >= 3:
				bonus["damage"] = 10
			if count >= 6:
				bonus["damage"] = 30
				bonus["crit"] = 0.15
		"defense":
			if count >= 3:
				bonus["hp"] = 25
			if count >= 6:
				bonus["hp"] = 75
		"vampire":
			if count >= 3:
				bonus["damage"] = 5
			if count >= 6:
				bonus["damage"] = 15
				bonus["hp"] = 30
		"utility":
			if count >= 3:
				bonus["xp"] = 0.15
			if count >= 6:
				bonus["xp"] = 0.40
				bonus["speed"] = 30
	
	return bonus
