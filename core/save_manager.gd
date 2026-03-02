extends Node

const SAVE_PATH = "user://save.cfg"

var gold = 0
var selected_character = 0
var meta_upgrades = {
	"max_hp_bonus": 0,
	"damage_bonus": 0,
	"speed_bonus": 0,
	"xp_bonus": 0,
	"luck_bonus": 0,
	"reroll_bonus": 0,
	"skip_bonus": 0,
	"magnet_bonus": 0,
	"cooldown_bonus": 0,
	"area_bonus": 0,
	"duration_bonus": 0,
	"multi_attack_bonus": 0,
	"recovery_bonus": 0,
	"armor_bonus": 0,
	"gold_bonus": 0,
	"crit_damage_bonus": 0,
	"start_level_bonus": 0,
	"growth_bonus": 0,
	"curse_level": 0,
	"revival": 0,
}
var settings = {
	"master_volume": 1.0,
	"sfx_volume": 1.0,
	"music_volume": 1.0,
	"fullscreen": false,
	"show_vfx": true,
	"screen_shake": true,
	"damage_numbers": "both_on",  # both_on, player_only, enemy_only, both_off
	"hp_bars": "both_on",         # both_on, player_only, enemy_only, both_off
}

# Kilit sistemi
var total_kills: int = 0
var max_survival_time: float = 0.0
var killed_tank: bool = false
var evolution_obtained: bool = false
var unique_chars_played: Array = []
var unlocked_characters: Array = ["warrior", "mage", "vampire"]
var purchased_characters: Array = ["warrior", "mage", "vampire"]

func _ready():
	load_game()

func save_game():
	var config = ConfigFile.new()
	config.set_value("player", "gold", gold)
	config.set_value("player", "selected_character", selected_character)
	for key in meta_upgrades:
		config.set_value("upgrades", key, meta_upgrades[key])
	for key in settings:
		config.set_value("settings", key, settings[key])
	config.set_value("unlock", "total_kills", total_kills)
	config.set_value("unlock", "max_survival_time", max_survival_time)
	config.set_value("unlock", "killed_tank", killed_tank)
	config.set_value("unlock", "evolution_obtained", evolution_obtained)
	config.set_value("unlock", "unique_chars_played", unique_chars_played)
	config.set_value("unlock", "unlocked_characters", unlocked_characters)
	config.set_value("unlock", "purchased_characters", purchased_characters)
	var err = config.save(SAVE_PATH)
	if err != OK:
		print("SaveManager: Kayıt başarısız! Hata kodu: ", err)

func load_game():
	var config = ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		print("SaveManager: Kayıt dosyası bulunamadı, varsayılan değerler kullanılıyor.")
		return
	gold = config.get_value("player", "gold", 0)
	selected_character = config.get_value("player", "selected_character", 0)
	selected_character = clamp(selected_character, 0, CharacterData.CHARACTERS.size() - 1)
	for key in meta_upgrades:
		meta_upgrades[key] = config.get_value("upgrades", key, 0)
	for key in settings:
		settings[key] = config.get_value("settings", key, settings[key])
	total_kills = config.get_value("unlock", "total_kills", 0)
	max_survival_time = config.get_value("unlock", "max_survival_time", 0.0)
	killed_tank = config.get_value("unlock", "killed_tank", false)
	evolution_obtained = config.get_value("unlock", "evolution_obtained", false)
	unique_chars_played = config.get_value("unlock", "unique_chars_played", [])
	unlocked_characters = config.get_value("unlock", "unlocked_characters", ["warrior", "mage", "vampire"])
	purchased_characters = config.get_value("unlock", "purchased_characters", ["warrior", "mage", "vampire"])

func add_gold(amount: int):
	var bonus = 1.0 + meta_upgrades["growth_bonus"] * 0.15
	gold += int(amount * bonus)
	save_game()

func spend_gold(amount: int) -> bool:
	if gold < amount:
		return false
	gold -= amount
	save_game()
	return true

func get_max_rank(key: String) -> int:
	match key:
		"reroll_bonus", "skip_bonus", "multi_attack_bonus", "crit_damage_bonus", "start_level_bonus":
			return 3
		"revival":
			return 1
		_:
			return 5

func get_upgrade_cost(key: String, current_rank: int) -> int:
	var base_cost = 100
	match key:
		"revival": base_cost = 400
		"curse_level": base_cost = 60
		"start_level_bonus": base_cost = 300
		"multi_attack_bonus": base_cost = 250
		"cooldown_bonus": base_cost = 180
		"area_bonus": base_cost = 180
		_: base_cost = 100
	return base_cost + current_rank * 60

func update_stats_after_game(char_id: String, kills: int, survival_time: float, got_evolution: bool, got_tank_kill: bool):
	total_kills += kills
	if survival_time > max_survival_time:
		max_survival_time = survival_time
	if got_evolution:
		evolution_obtained = true
	if got_tank_kill:
		killed_tank = true
	if not unique_chars_played.has(char_id):
		unique_chars_played.append(char_id)
	check_and_unlock_characters(char_id, kills, survival_time)
	save_game()

func check_and_unlock_characters(char_id: String, run_kills: int, survival_time: float):
	for char_data in CharacterData.CHARACTERS:
		var cid = char_data["id"]
		if unlocked_characters.has(cid):
			continue
		var cond = char_data["unlock_condition"]
		if cond.is_empty():
			continue
		var unlocked = false
		match cond["type"]:
			"total_kills":
				unlocked = total_kills >= cond["amount"]
			"max_survival":
				unlocked = max_survival_time >= cond["amount"]
			"killed_tank":
				unlocked = killed_tank
			"evolution_obtained":
				unlocked = evolution_obtained
			"unique_chars_played":
				unlocked = unique_chars_played.size() >= cond["amount"]
			"single_run_kills":
				unlocked = run_kills >= cond["amount"]
			"survive_as":
				unlocked = (char_id == cond["character"] and survival_time >= cond["amount"])
		if unlocked:
			unlocked_characters.append(cid)

func purchase_character(char_id: String) -> bool:
	for char_data in CharacterData.CHARACTERS:
		if char_data["id"] == char_id:
			var cost = char_data["cost"]
			if gold >= cost and unlocked_characters.has(char_id):
				gold -= cost
				purchased_characters.append(char_id)
				save_game()
				return true
	return false

func is_unlocked(char_id: String) -> bool:
	return unlocked_characters.has(char_id)

func is_purchased(char_id: String) -> bool:
	return purchased_characters.has(char_id)

func reset_meta_upgrades():
	for key in meta_upgrades:
		meta_upgrades[key] = 0
	save_game()
