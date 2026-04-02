extends Node

const SAVE_PATH = "user://save.cfg"

var gold = 0
var selected_mode = "vs"
var selected_map = "vs_map"
var selected_character = 0
var game_mode: String = "solo"  # "solo", "local_coop", "online_coop"
var selected_character_p2: int = 1
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
	"adrenaline": 0,
	"momentum": 0,
	"overheal": 0,
}
var settings = {
	"master_volume": 1.0,
	"sfx_volume": 1.0,
	"music_volume": 1.0,
	"fullscreen": false,
	"show_vfx": true,
	"screen_shake": true,
	"damage_numbers": "both_on",
	"hp_bars": "both_on",
	"resolution_x": 1280,
	"resolution_y": 720,
}

# Kilit sistemi
var total_kills: int = 0
var max_survival_time: float = 0.0
var total_gold_earned: int = 0
var total_xp_earned: int = 0
var total_levels_gained: int = 0
var total_bosses_killed: int = 0
var total_runs: int = 0
var total_wins: int = 0
var best_kill_run: int = 0
var total_damage_dealt: int = 0
var total_chests_opened: int = 0
var total_items_collected: int = 0
var total_deaths: int = 0
var killed_tank: bool = false
var evolution_obtained: bool = false
var unique_chars_played: Array = []
var unlocked_achievements: Array = []
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
	config.set_value("stats", "total_gold_earned", total_gold_earned)
	config.set_value("stats", "total_xp_earned", total_xp_earned)
	config.set_value("stats", "total_levels_gained", total_levels_gained)
	config.set_value("stats", "total_bosses_killed", total_bosses_killed)
	config.set_value("stats", "total_runs", total_runs)
	config.set_value("stats", "total_wins", total_wins)
	config.set_value("stats", "best_kill_run", best_kill_run)
	config.set_value("stats", "total_damage_dealt", total_damage_dealt)
	config.set_value("stats", "total_chests_opened", total_chests_opened)
	config.set_value("stats", "total_items_collected", total_items_collected)
	config.set_value("stats", "total_deaths", total_deaths)
	config.set_value("unlock", "killed_tank", killed_tank)
	config.set_value("unlock", "evolution_obtained", evolution_obtained)
	config.set_value("unlock", "unique_chars_played", unique_chars_played)
	config.set_value("unlock", "unlocked_characters", unlocked_characters)
	config.set_value("unlock", "unlocked_achievements", unlocked_achievements)
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
	total_gold_earned = config.get_value("stats", "total_gold_earned", 0)
	total_xp_earned = config.get_value("stats", "total_xp_earned", 0)
	total_levels_gained = config.get_value("stats", "total_levels_gained", 0)
	total_bosses_killed = config.get_value("stats", "total_bosses_killed", 0)
	total_runs = config.get_value("stats", "total_runs", 0)
	total_wins = config.get_value("stats", "total_wins", 0)
	best_kill_run = config.get_value("stats", "best_kill_run", 0)
	total_damage_dealt = config.get_value("stats", "total_damage_dealt", 0)
	total_chests_opened = config.get_value("stats", "total_chests_opened", 0)
	total_items_collected = config.get_value("stats", "total_items_collected", 0)
	total_deaths = config.get_value("stats", "total_deaths", 0)
	killed_tank = config.get_value("unlock", "killed_tank", false)
	evolution_obtained = config.get_value("unlock", "evolution_obtained", false)
	unique_chars_played = config.get_value("unlock", "unique_chars_played", [])
	unlocked_characters = config.get_value("unlock", "unlocked_characters", ["warrior", "mage", "vampire"])
	unlocked_achievements = config.get_value("unlock", "unlocked_achievements", [])
	purchased_characters = config.get_value("unlock", "purchased_characters", ["warrior", "mage", "vampire"])
	var res_x = settings.get("resolution_x", 1280)
	var res_y = settings.get("resolution_y", 720)
	if not settings.get("fullscreen", false):
		DisplayServer.window_set_size(Vector2i(res_x, res_y))

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
		"adrenaline", "momentum", "overheal":
			return 5
		_:
			return 5

func get_upgrade_cost(key: String, current_rank: int) -> int:
	var initial_prices = {
		"max_hp_bonus": 100,
		"damage_bonus": 150,
		"speed_bonus": 100,
		"xp_bonus": 120,
		"luck_bonus": 200,
		"reroll_bonus": 300,
		"skip_bonus": 100,
		"magnet_bonus": 80,
		"cooldown_bonus": 250,
		"area_bonus": 200,
		"duration_bonus": 150,
		"multi_attack_bonus": 400,
		"recovery_bonus": 100,
		"armor_bonus": 150,
		"gold_bonus": 120,
		"crit_damage_bonus": 300,
		"start_level_bonus": 500,
		"growth_bonus": 120,
		"curse_level": 80,
		"revival": 600,
		"adrenaline": 250,
		"momentum": 250,
		"overheal": 200,
	}
	var initial = initial_prices.get(key, 100)
	var bought = current_rank
	var total_bought = _get_total_bought()
	var base_cost = initial * (1 + bought)
	var fees = 0 if total_bought == 0 else int(20.0 * pow(1.1, total_bought))
	return base_cost + fees

func _get_total_bought() -> int:
	var total = 0
	for key in meta_upgrades:
		total += meta_upgrades[key]
	return total

func update_stats_after_game(char_id: String, kills: int, survival_time: float, got_evolution: bool, got_tank_kill: bool, gold: int = 0, xp_levels: int = 0, bosses: int = 0, damage: int = 0, chests: int = 0, items: int = 0, won: bool = false):
	total_kills += kills
	total_runs += 1
	total_deaths += 1
	total_gold_earned += gold
	total_levels_gained += xp_levels
	total_bosses_killed += bosses
	total_damage_dealt += damage
	total_chests_opened += chests
	total_items_collected += items
	if won:
		total_wins += 1
		total_deaths -= 1
	if kills > best_kill_run:
		best_kill_run = kills
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
