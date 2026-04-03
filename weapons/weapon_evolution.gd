class_name WeaponEvolution
extends Node

const EVOLUTIONS = {
	"holy_bullet": {
		"requires_weapons": ["bullet"],
		"requires_items": ["armor"],
		"name": "Holy Bullet",
		"description": "Mermi + Zırh → Kutsal Mermi\n+%50 hasar, düşman zırhını kırar"
	},
	"toxic_chain": {
		"requires_weapons": ["chain"],
		"requires_items": ["poison"],
		"name": "Toxic Chain",
		"description": "Zincir + Zehir → Zehirli Zincir\nZincirleme atlarken zehir yayar"
	},
	"death_laser": {
		"requires_weapons": ["laser"],
		"requires_items": ["crit"],
		"name": "Death Laser",
		"description": "Lazer + Kritik → Ölüm Lazeri\nHer vuruş kritik, menzil 2x"
	},
	"blood_boomerang": {
		"requires_weapons": ["boomerang"],
		"requires_items": ["lifesteal"],
		"name": "Blood Boomerang",
		"description": "Bumerang + Can Çalma → Kan Bumerangı\nVurdukça can çalar"
	},
	"storm": {
		"requires_weapons": ["lightning"],
		"requires_items": ["speed_charm"],
		"name": "Storm",
		"description": "Yıldırım + Hız Tılsımı → Fırtına\nHer öldürmede ekstra yıldırım"
	},
	"shadow_storm": {
		"requires_weapons": ["shadow", "lightning"],
		"requires_items": ["speed_charm"],
		"name": "Gölge Fırtınası",
		"description": "Gölge + Yıldırım + Hız → Gölge Fırtınası\nHer gölge vuruşu yıldırım zinciri tetikler"
	},
	"frost_nova": {
		"requires_weapons": ["ice_ball"],
		"requires_items": ["armor", "shield"],
		"name": "Buz Novas",
		"description": "Buz Topu + Zırh + Kalkan → Buz Novas\nVuruşta alan dondurma + hasar yansıtma"
	},
}

static func get_available_evolutions(player) -> Array:
	var available = []
	for evo_id in EVOLUTIONS:
		var evo = EVOLUTIONS[evo_id]
		var has_all_weapons = true
		var has_all_items = true
		
		# Silahlar max level de olmalı
		for w in evo["requires_weapons"]:
			if not player.active_weapons.has(w):
				has_all_weapons = false
				break
			var weapon = player.active_weapons[w]
			var required_level = weapon.max_level
			if player.get("blood_oath_active") and player.blood_oath_active:
				required_level = max(1, weapon.max_level / 2)
			if weapon.level < required_level:
				has_all_weapons = false
				break
		
		for i in evo["requires_items"]:
			if not player.active_items.has(i):
				has_all_items = false
				break
			var item = player.active_items[i]
			if item.level < item.max_level:
				has_all_items = false
				break
		# Zaten evrim yapılmış mı?
		if player.active_weapons.has(evo_id):
			continue
		
		if has_all_weapons and has_all_items:
			available.append(evo_id)
	
	return available
