extends Node

const SAVE_PATH = "user://save.cfg"

var gold = 0
var selected_mode = "vs"
var selected_map = "vs_map"
var selected_character = 0
var game_mode: String = "solo"  # "solo", "local_coop", "online_coop"
var selected_character_p2: int = 0
## Karakter listesi sırası değişse bile doğru kahraman; boşsa indeksten türetilir.
var selected_character_id: String = "warrior"
var selected_character_p2_id: String = "warrior"
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
	"player_vfx_opacity": 1.0,
	"damage_numbers": "both_on",
	"hp_bars": "both_on",
	"resolution_x": 1280,
	"resolution_y": 720,
	"locale": "tr",
	"pause_on_focus_loss": true,
	"enemy_high_contrast_outline": false,
	"input_keyboard_overrides": {},
	## "high" | "medium" | "low" — düşman üst sınırı, olay spawn yoğunluğu, VFX/partikül.
	"performance_quality": "high",
	## Koşu seçimi (map_select): "story" | "fast" | "arena"
	"run_variant": "story",
	## 0–5: koşu başı zorluk / lanet kademesi
	"run_curse_tier": 0,
	## Renk körlüğü: "none" | "friendly"
	"colorblind_palette": "none",
	## Arayüz metin/ölçek (~0.85–1.35)
	"ui_scale": 1.0,
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
var unlocked_characters: Array = ["warrior"]
var purchased_characters: Array = ["warrior"]
## Kodeks: ilk kez öldürülen düşman/boss (`CollectionData.has_bestiary_id`).
var codex_discovered: Array = []
## Kodeks: koşuda ilk kez alınan silah / eşya; oynanan harita.
var codex_weapons: Array = []
var codex_items: Array = []
var codex_maps: Array = []

const CHARACTER_ORDER_V2_KEY = "character_order_v2"
const OLD_CHARACTER_ORDER: Array[String] = [
	"warrior", "mage", "vampire", "hunter", "stormer", "frost", "shadow_walker",
	"engineer", "paladin", "blood_prince", "death_knight", "chaos", "omega", "nomad",
	"sigil_warden", "grav_binder", "ironclad", "linebreaker",
]

func _ready():
	load_game()
	set_process_unhandled_input(true)


func apply_window_mode_from_settings() -> void:
	if settings.get("fullscreen", false):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		var res_x: int = int(settings.get("resolution_x", 1280))
		var res_y: int = int(settings.get("resolution_y", 720))
		DisplayServer.window_set_size(Vector2i(res_x, res_y))


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_fullscreen"):
		settings["fullscreen"] = not settings.get("fullscreen", false)
		apply_window_mode_from_settings()
		save_game()
		if get_viewport():
			get_viewport().set_input_as_handled()

func save_game():
	_normalize_meta_upgrades()
	var config = ConfigFile.new()
	config.set_value("player", "gold", gold)
	config.set_value("player", "selected_character", selected_character)
	config.set_value("player", "selected_character_p2", selected_character_p2)
	config.set_value("player", "selected_character_id", selected_character_id)
	config.set_value("player", "selected_character_p2_id", selected_character_p2_id)
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
	config.set_value("unlock", "codex_discovered", codex_discovered)
	config.set_value("unlock", "codex_weapons", codex_weapons)
	config.set_value("unlock", "codex_items", codex_items)
	config.set_value("unlock", "codex_maps", codex_maps)
	config.set_value("player", CHARACTER_ORDER_V2_KEY, true)
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
	selected_character_p2 = config.get_value("player", "selected_character_p2", 0)
	if not config.get_value("player", CHARACTER_ORDER_V2_KEY, false):
		selected_character = _remap_character_index_after_order_change(selected_character)
		selected_character_p2 = _remap_character_index_after_order_change(selected_character_p2)
	selected_character = clampi(selected_character, 0, CharacterData.CHARACTERS.size() - 1)
	selected_character_p2 = clampi(selected_character_p2, 0, CharacterData.CHARACTERS.size() - 1)
	selected_character_id = str(config.get_value("player", "selected_character_id", ""))
	selected_character_p2_id = str(config.get_value("player", "selected_character_p2_id", ""))
	_reconcile_selected_characters_from_storage()
	for key in meta_upgrades:
		meta_upgrades[key] = config.get_value("upgrades", key, 0)
	_normalize_meta_upgrades()
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
	unlocked_characters = config.get_value("unlock", "unlocked_characters", ["warrior"])
	unlocked_achievements = config.get_value("unlock", "unlocked_achievements", [])
	purchased_characters = config.get_value("unlock", "purchased_characters", ["warrior"])
	codex_discovered = config.get_value("unlock", "codex_discovered", [])
	codex_weapons = config.get_value("unlock", "codex_weapons", [])
	codex_items = config.get_value("unlock", "codex_items", [])
	codex_maps = config.get_value("unlock", "codex_maps", [])
	apply_window_mode_from_settings()

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

func _normalize_meta_upgrades() -> void:
	for key in meta_upgrades:
		var cap: int = get_max_rank(key)
		meta_upgrades[key] = clampi(int(meta_upgrades[key]), 0, cap)


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

func _remap_character_index_after_order_change(old_index: int) -> int:
	var idx = clampi(old_index, 0, OLD_CHARACTER_ORDER.size() - 1)
	var cid: String = OLD_CHARACTER_ORDER[idx]
	for i in CharacterData.CHARACTERS.size():
		if CharacterData.CHARACTERS[i]["id"] == cid:
			return i
	return clampi(old_index, 0, CharacterData.CHARACTERS.size() - 1)


func _reconcile_selected_characters_from_storage() -> void:
	var n: int = CharacterData.CHARACTERS.size()
	if n <= 0:
		return
	selected_character = clampi(selected_character, 0, n - 1)
	selected_character_p2 = clampi(selected_character_p2, 0, n - 1)
	# P1: geçerli ID yoksa mevcut indeksten türet; varsa indeksi ID ile eşitle
	if selected_character_id.is_empty() or CharacterData.get_character_index_by_id(selected_character_id) < 0:
		selected_character_id = str(CharacterData.CHARACTERS[selected_character]["id"])
	else:
		var i1: int = CharacterData.get_character_index_by_id(selected_character_id)
		if i1 >= 0:
			selected_character = i1
		else:
			selected_character_id = str(CharacterData.CHARACTERS[0]["id"])
			selected_character = 0
	# P2
	if selected_character_p2_id.is_empty() or CharacterData.get_character_index_by_id(selected_character_p2_id) < 0:
		selected_character_p2_id = str(CharacterData.CHARACTERS[selected_character_p2]["id"])
	else:
		var i2: int = CharacterData.get_character_index_by_id(selected_character_p2_id)
		if i2 >= 0:
			selected_character_p2 = i2
		else:
			selected_character_p2_id = str(CharacterData.CHARACTERS[0]["id"])
			selected_character_p2 = 0


func get_character_index_for_player(player_id: int) -> int:
	var n: int = CharacterData.CHARACTERS.size()
	if n <= 0:
		return 0
	var cid: String = selected_character_p2_id if player_id == 1 else selected_character_id
	var by_id: int = CharacterData.get_character_index_by_id(cid)
	if by_id >= 0:
		return by_id
	var idx: int = selected_character_p2 if player_id == 1 else selected_character
	return clampi(idx, 0, n - 1)


func set_selected_character_p1_index(index: int) -> void:
	var n: int = CharacterData.CHARACTERS.size()
	if n <= 0:
		return
	selected_character = clampi(index, 0, n - 1)
	selected_character_id = str(CharacterData.CHARACTERS[selected_character]["id"])


func set_selected_character_p2_index(index: int) -> void:
	var n: int = CharacterData.CHARACTERS.size()
	if n <= 0:
		return
	selected_character_p2 = clampi(index, 0, n - 1)
	selected_character_p2_id = str(CharacterData.CHARACTERS[selected_character_p2]["id"])


func get_character_id_for_player(player_id: int) -> String:
	var i: int = get_character_index_for_player(player_id)
	return str(CharacterData.CHARACTERS[i]["id"])


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


func register_codex_discovered(entry_id: String) -> void:
	if entry_id.is_empty():
		return
	if not CollectionData.has_bestiary_id(entry_id):
		return
	if codex_discovered.has(entry_id):
		return
	codex_discovered.append(entry_id)
	save_game()


func register_codex_weapon(weapon_id: String) -> void:
	if weapon_id.is_empty() or not CollectionData.is_valid_weapon_codex_id(weapon_id):
		return
	if codex_weapons.has(weapon_id):
		return
	codex_weapons.append(weapon_id)
	save_game()


func register_codex_item(item_id: String) -> void:
	if item_id.is_empty() or not CollectionData.is_valid_item_codex_id(item_id):
		return
	if codex_items.has(item_id):
		return
	codex_items.append(item_id)
	save_game()


func register_codex_map(map_id: String) -> void:
	if map_id.is_empty() or not CollectionData.is_valid_map_codex_id(map_id):
		return
	if codex_maps.has(map_id):
		return
	codex_maps.append(map_id)
	save_game()


func is_codex_discovered(entry_id: String) -> bool:
	return codex_discovered.has(entry_id)


func is_codex_entry_unlocked(entry: Dictionary) -> bool:
	var tab: String = str(entry.get("tab", ""))
	var id: String = str(entry.get("id", ""))
	match tab:
		"enemy", "boss":
			return codex_discovered.has(id)
		"weapon":
			return codex_weapons.has(id)
		"item":
			return codex_items.has(id)
		"character":
			return unlocked_characters.has(id)
		"map":
			return codex_maps.has(id)
		_:
			return false

func get_performance_quality() -> String:
	var q := str(settings.get("performance_quality", "high"))
	if q != "low" and q != "medium" and q != "high":
		return "high"
	return q


func get_max_enemies_cap() -> int:
	match get_performance_quality():
		"low":
			return 320
		"medium":
			return 650
		_:
			return 1200


## Patlama / ölüm partikülleri vb.; `show_vfx` kapalıysa veya düşük kalitede kapalı.
func is_heavy_vfx_enabled() -> bool:
	if not settings.get("show_vfx", true):
		return false
	if get_performance_quality() == "low":
		return false
	return true


func get_particle_burst_count(base: int) -> int:
	var m := get_particle_budget_mult()
	return maxi(1, int(round(float(base) * m)))


func get_particle_budget_mult() -> float:
	match get_performance_quality():
		"low":
			return 0.35
		"medium":
			return 0.65
		_:
			return 1.0


func get_swarm_event_count_mult() -> float:
	match get_performance_quality():
		"low":
			return 0.45
		"medium":
			return 0.72
		_:
			return 1.0


func get_encircle_event_count_mult() -> float:
	match get_performance_quality():
		"low":
			return 0.5
		"medium":
			return 0.78
		_:
			return 1.0


const STORY_RUN_GOAL_SEC: float = 1800.0
const FAST_RUN_GOAL_SEC: float = 840.0


func is_fast_run() -> bool:
	return str(settings.get("run_variant", "story")) == "fast"


func get_run_goal_sec() -> float:
	return FAST_RUN_GOAL_SEC if is_fast_run() else STORY_RUN_GOAL_SEC


func get_run_curse_tier() -> int:
	return clampi(int(settings.get("run_curse_tier", 0)), 0, 5)


func get_mini_boss_times() -> Array:
	if is_fast_run():
		var f: float = get_run_goal_sec() / STORY_RUN_GOAL_SEC
		return [int(300 * f), int(600 * f), int(900 * f), int(1200 * f), int(1500 * f)]
	return [300, 600, 900, 1200, 1500]


func get_midpoint_music_sec() -> float:
	return get_run_goal_sec() * 0.5


func get_immunity_phase_start_sec() -> float:
	return get_run_goal_sec() * 0.5


func get_ui_scale() -> float:
	return clampf(float(settings.get("ui_scale", 1.0)), 0.82, 1.38)


func get_colorblind_mode() -> String:
	var m := str(settings.get("colorblind_palette", "none"))
	return m if m == "friendly" or m == "none" else "none"


func filter_accessibility_orb_color(c: Color) -> Color:
	if get_colorblind_mode() != "friendly":
		return c
	var h := c.h
	var s := c.s
	var v := c.v
	if h < 0.07 or h > 0.92:
		return Color.from_hsv(0.08, minf(s, 0.88), v)
	if h > 0.22 and h < 0.48:
		return Color.from_hsv(0.56, minf(s, 0.88), v)
	return c


## 0 = biraz kolay, 5 = zor; spawn aralığı / min düşman ile çarpılır.
func get_run_spawn_difficulty_mult() -> float:
	var t := float(get_run_curse_tier())
	return lerpf(0.88, 1.26, t / 5.0)


func reset_meta_upgrades():
	for key in meta_upgrades:
		meta_upgrades[key] = 0
	save_game()
