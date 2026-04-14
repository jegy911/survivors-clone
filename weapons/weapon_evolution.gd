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
		"name": "Kan Baltası",
		"description": "Balta + Can Çalma → Kan Baltası\nVurdukça can çalar"
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
	"ember_fan": {
		"requires_weapons": ["fan_blade"],
		"requires_items": ["ember_heart"],
		"name": "Kor Yelpazesi",
		"description": "Yelpaze Bıçak (MAX) + Kor Kalbi (MAX) → Kor Yelpazesi\nDaha geniş yelpaze, delici kor kılıçları"
	},
	"binding_circle": {
		"requires_weapons": ["hex_sigil"],
		"requires_items": ["glyph_charm"],
		"name": "Bağlayıcı Halka",
		"description": "Altıgön Mühür + Rün Tılsımı → Bağlayıcı Halka\nGeniş alan, güçlü yavaşlatma ve hasar"
	},
	"void_lens": {
		"requires_weapons": ["gravity_anchor"],
		"requires_items": ["resonance_stone"],
		"name": "Uçurum Merceği",
		"description": "Çekim Çapası + Rezonans Taşı → Uçurum Merceği\nDaha güçlü çekim ve alan hasarı"
	},
	"citadel_flail": {
		"requires_weapons": ["bastion_flail"],
		"requires_items": ["rampart_plate"],
		"name": "Hisar Zinciri",
		"description": "Kale Gürzü + Rampa Plakası → Hisar Zinciri\nGeniş alan, yüksek itme ve hasar"
	},
	"fortress_ram": {
		"requires_weapons": ["shield_ram"],
		"requires_items": ["iron_bulwark"],
		"name": "Kale Sur Koşusu",
		"description": "Kalkan Hamlesi + Demir Siper → Kale Sur Koşusu\nGeniş koni, sur gibi baskı"
	},
}

static func _meets_weapon_requirements(player, evo: Dictionary) -> bool:
	for w in evo["requires_weapons"]:
		if not player.active_weapons.has(w):
			return false
		var weapon = player.active_weapons[w]
		var required_level = weapon.max_level
		if player.get("blood_oath_active") and player.blood_oath_active:
			required_level = max(1, weapon.max_level / 2)
		if weapon.level < required_level:
			return false
	return true


static func _meets_item_requirements(player, evo: Dictionary) -> bool:
	for i in evo["requires_items"]:
		if not player.active_items.has(i):
			return false
		var item = player.active_items[i]
		if item.level < item.max_level:
			return false
	return true


## Gerekli silah/eşya MAX, evrim silahı henüz yok.
static func is_evolution_ready(player, evo_id: String) -> bool:
	if not EVOLUTIONS.has(evo_id):
		return false
	if player.active_weapons.has(evo_id):
		return false
	var evo = EVOLUTIONS[evo_id]
	return _meets_weapon_requirements(player, evo) and _meets_item_requirements(player, evo)


static func get_available_evolutions(player) -> Array:
	var available: Array = []
	for evo_id in EVOLUTIONS:
		if is_evolution_ready(player, evo_id):
			available.append(evo_id)
	available.shuffle()
	return available


static func get_evolution_weight(evo_id: String) -> float:
	if not EVOLUTIONS.has(evo_id):
		return 10.0
	return float(EVOLUTIONS[evo_id].get("weight", 10.0))


static func localized_name(evo_id: String) -> String:
	if not EVOLUTIONS.has(evo_id):
		return evo_id
	var key = "ui.evolution_defs.%s.name" % evo_id
	var t = TranslationServer.translate(key)
	if t == key:
		return str(EVOLUTIONS[evo_id]["name"])
	return t


static func localized_description(evo_id: String) -> String:
	if not EVOLUTIONS.has(evo_id):
		return ""
	var key = "ui.evolution_defs.%s.desc" % evo_id
	var t = TranslationServer.translate(key)
	if t == key:
		return str(EVOLUTIONS[evo_id]["description"])
	return t
