extends CharacterBody2D

## `ui/upgrade_ui.gd` havuzları ile aynı sıra — level-up seçiminde `add_weapon` / `add_item` eşlemesi.
const _LEVELUP_WEAPON_IDS: PackedStringArray = [
	"bullet", "aura", "chain", "boomerang", "lightning", "ice_ball", "shadow", "laser", "fan_blade",
	"hex_sigil", "gravity_anchor", "bastion_flail", "shield_ram",
]
const _LEVELUP_ITEM_IDS: PackedStringArray = [
	"lifesteal", "armor", "crit", "explosion", "magnet", "poison", "shield", "speed_charm", "blood_pool",
	"luck_stone", "turbine", "steam_armor", "energy_cell", "ember_heart", "glyph_charm", "resonance_stone",
	"rampart_plate", "iron_bulwark",
]

var player_id: int = 0
var BASE_SPEED = 130.0
var SPEED = 130.0
## Yer hareketi üst sınırı (level / meta / tılsım ile taşmasın).
const MAX_MOVE_SPEED: float = 300.0
var hp = 100
var max_hp = 100
var bullet_damage = 10
var shake_intensity = 0.0
var shake_duration = 0.0

var xp = 0
var level = 1
var xp_to_next_level = 30
var kill_count = 0
var gold_earned = 0
var boss_kill_count = 0
var total_damage_dealt = 0
var chests_opened = 0
var momentum_timer = 0.0
var momentum_bonus = 0
var last_position = Vector2.ZERO
var overheal_shield = 0
var bounce_timer = 0.0
var shrine_active = false
var shrine_timer = 0.0
var trail_timer = 0.0
var _origin_area_bonus = 0.0
var _origin_cooldown_bonus = 0.0
var _origin_armor_bonus = 0
var _origin_xp_bonus = 0.0
var collection_regen_timer = 0.0


func _ready_damage_tracking():
	EventBus.on_damage_dealt.connect(_on_damage_tracked)

func _on_damage_tracked(p: Node, _enemy: Node, damage: int):
	if p == self:
		total_damage_dealt += damage

# Revival
var revival_used = false
var is_downed: bool = false
var tank_killed = false        # YENİ
var evolution_obtained = false # YENİ
var cog_shard_count: int = 0
var cog_shard_bonus_active: bool = false
var blood_oath_active: bool = false
var blood_oath_timer: float = 0.0
const BLOOD_OATH_DURATION: float = 30.0

# Pasif iyileşme sayacı
var recovery_timer = 0.0

# Combo / kill streak
var recent_kill_times: Array = []

var upgrade_ui_scene = preload("res://ui/upgrade_ui.tscn")
var game_over_scene = preload("res://ui/game_over.tscn")
var upgrade_ui = null

var active_weapons = {}
var active_items = {}

var max_weapons = 5
var max_items = 5

var category_counts = {
	"attack": 0,
	"defense": 0,
	"vampire": 0,
	"utility": 0,
}

var category_damage_bonus = 0
var category_crit_bonus = 0.0
var category_xp_bonus = 0.0
var category_speed_bonus = 0
var category_hp_bonus = 0

@onready var xp_bar = $CanvasLayer/XPBar
@onready var hp_bar_fill = $WorldUI/HPBarFill
@onready var hp_bar_bg = $WorldUI/HPBarBG
@onready var attack_label = $CanvasLayer/CategoryPanel/VBoxContainer/AttackLabel
@onready var defense_label = $CanvasLayer/CategoryPanel/VBoxContainer/DefenseLabel
@onready var vampire_label = $CanvasLayer/CategoryPanel/VBoxContainer/VampireLabel
@onready var utility_label = $CanvasLayer/CategoryPanel/VBoxContainer/UtilityLabel
var _body_base_color = Color.WHITE

@onready var body = $ColorRect

func _ready():
	max_hp = 100
	hp = 100
	apply_meta_bonuses()
	apply_character_bonuses()
	$CanvasLayer/StatsRow/KillLabel.text = "💀 0"
	$CanvasLayer/StatsRow/GoldLabel.text = "💰 0"
	_update_cog_label()
	
	xp_bar.max_value = xp_to_next_level
	xp_bar.min_value = 0
	xp_bar.value = 0
	xp_bar.show_percentage = false
	# XP bar boyutunu ekrana göre ayarla
	xp_bar.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	xp_bar.custom_minimum_size.x = 0
	xp_bar.size.y = 18
	
	update_hp_bar()
	update_category_ui()
	_setup_player_visuals()
	# Co-op modunda CanvasLayer'ı gizle
	if SaveManager.game_mode == "local_coop":
		$CanvasLayer.visible = false
	
	# Stats butonu HUD'a ekle
	var stats_btn = Button.new()
	stats_btn.text = "📊"
	stats_btn.custom_minimum_size = Vector2(40, 40)
	stats_btn.position = Vector2(10, 10)
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color("#1A1A2EAA")
	btn_style.corner_radius_top_left = 6
	btn_style.corner_radius_top_right = 6
	btn_style.corner_radius_bottom_left = 6
	btn_style.corner_radius_bottom_right = 6
	stats_btn.add_theme_stylebox_override("normal", btn_style)
	stats_btn.pressed.connect(_on_stats_button_pressed)
	$CanvasLayer.add_child(stats_btn)
	# Co-op: player_id'ye göre input ayarla
	_setup_input()
	EventBus.player_damaged.connect(_on_player_damaged)
	EventBus.boss_spawned.connect(_on_boss_spawned)
	_ready_damage_tracking()

func apply_character_bonuses():
	var char_index: int = SaveManager.get_character_index_for_player(player_id)
	var char_data = CharacterData.CHARACTERS[char_index]
	_body_base_color = Color(char_data["color"])
	body.color = _body_base_color
	bullet_damage += char_data["bonus_damage"]
	max_hp += char_data["bonus_hp"]
	hp = max_hp
	SPEED += char_data["bonus_speed"]
	if char_data["start_weapon"] != "" and not active_weapons.has(char_data["start_weapon"]):
		add_weapon(char_data["start_weapon"])
	if char_data["start_item"] != "":
		add_item(char_data["start_item"])
	var origin = char_data.get("origin_bonus", {})
	if not origin.is_empty():
		match origin.get("type", ""):
			"damage_flat":
				bullet_damage += origin["amount"]
			"area_pct":
				_origin_area_bonus = origin["amount"]
			"speed_pct":
				SPEED = int(SPEED * (1.0 + origin["amount"]))
			"cooldown_pct":
				_origin_cooldown_bonus = origin["amount"]
			"armor_flat":
				_origin_armor_bonus = origin["amount"]
			"xp_pct":
				_origin_xp_bonus = origin["amount"]
			"hp_pct":
				max_hp = int(max_hp * (1.0 + origin["amount"]))
				hp = max_hp
			"single_weapon":
				max_weapons = 1
		# Penalty uygula
		var penalty = origin.get("penalty", "none")
		var penalty_amount = origin.get("penalty_amount", 0.0)
		match penalty:
			"speed_pct":
				SPEED = int(SPEED * (1.0 + penalty_amount))
			"hp_pct":
				max_hp = int(max_hp * (1.0 + penalty_amount))
				hp = max_hp
			"damage_pct":
				bullet_damage = int(bullet_damage * (1.0 + penalty_amount))
	var special = char_data.get("special", "")
	if special == "all_weapons_1hp":
		max_hp = 1
		hp = 1
	elif special == "damage_double":
		bullet_damage *= 2
	elif special == "random_weapons":
		var all_weapons = ["bullet", "aura", "chain", "boomerang", "lightning", "ice_ball", "shadow", "laser", "fan_blade", "hex_sigil", "gravity_anchor", "bastion_flail", "shield_ram"]
		all_weapons.shuffle()
		for w in all_weapons.slice(0, 3):
			add_weapon(w)
	SPEED = minf(float(SPEED), MAX_MOVE_SPEED)

func apply_meta_bonuses():
	var meta = SaveManager.meta_upgrades
	
	# Mevcut bonuslar
	max_hp += meta["max_hp_bonus"] * 25
	hp = max_hp
	bullet_damage += meta["damage_bonus"] * 5
	SPEED += meta["speed_bonus"] * 10
	SPEED = minf(float(SPEED), MAX_MOVE_SPEED)
	
	# Başlangıç zırhı — take_damage'de kullanılıyor
	# (armor_bonus direkt orada okunuyor)
	
	# Başlangıç seviyesi: meta rank en fazla 3 satın alınır; **oyunda en fazla +1 net level** (Lv2’de başla) — rank 2–3 ileride XP vb. ile genişletilebilir.
	const START_LEVEL_META_CAP: int = 3
	const START_LEVEL_MAX_GRANTED: int = 1
	var raw_sl: int = clampi(int(meta.get("start_level_bonus", 0)), 0, START_LEVEL_META_CAP)
	var granted: int = mini(raw_sl, START_LEVEL_MAX_GRANTED)
	for _i in range(granted):
		level += 1
		xp_to_next_level = _calc_xp_for_level(level)
	
	# Revival — oyun başında sıfırla
	revival_used = false

func get_effective_move_speed() -> float:
	return minf(float(SPEED), MAX_MOVE_SPEED)


func _physics_process(delta):
	var direction = _get_input_direction()
	velocity = direction.normalized() * get_effective_move_speed()
	move_and_slide()
	_update_animation(direction)

func _get_input_direction() -> Vector2:
	match player_id:
		0:
			var d := Input.get_vector("p2_left", "p2_right", "p2_up", "p2_down")
			if d.length_squared() < 0.01:
				d = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
			return d
		1:
			return Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		_:
			return Vector2.ZERO

func _update_animation(direction: Vector2):
	var sprite = get_node_or_null("AnimatedSprite2D")
	if sprite == null:
		return
	if direction == Vector2.ZERO:
		if sprite.animation == "walk_left":
			sprite.play("idle_left")
			sprite.flip_h = false
		elif sprite.animation == "walk_right":
			sprite.play("idle_right")
			sprite.flip_h = false
	else:
		if direction.x >= 0:
			sprite.play("walk_right")
			sprite.flip_h = false
		else:
			sprite.play("walk_left")
			sprite.flip_h = false

func _process(delta):
	# Pasif can yenileme
	var recovery = SaveManager.meta_upgrades.get("recovery_bonus", 0)
	if recovery > 0:
		recovery_timer += delta
		if recovery_timer >= 60.0:
			recovery_timer = 0.0
			heal(recovery * 3)
	
	# Momentum — hareket edince hasar bonusu
	var momentum_rank = SaveManager.meta_upgrades.get("momentum", 0)
	if momentum_rank > 0:
		if global_position.distance_to(last_position) > 2.0:
			momentum_timer += delta
			momentum_bonus = min(int(momentum_timer) * momentum_rank, momentum_rank * 10)
		else:
			momentum_timer = max(0.0, momentum_timer - delta * 2)
			momentum_bonus = min(int(momentum_timer) * momentum_rank, momentum_rank * 10)
		last_position = global_position
		# Blood Oath timer
	if blood_oath_active:
		blood_oath_timer -= delta
		if blood_oath_timer <= 0:
			blood_oath_active = false
			show_floating_text("🩸 Kan Yemini bitti", global_position + Vector2(0, -60), Color("#8B0000"), 14)
	# Bounce timer
	if bounce_timer > 0:
		bounce_timer -= delta
	
	# Shrine timer
	if shrine_active:
		shrine_timer -= delta
		if shrine_timer <= 0:
			shrine_active = false
			show_floating_text("🕯 Sunak bitti", global_position + Vector2(0, -60), Color("#AAAAAA"))
	_update_screen_shake(delta)

	# Hız Sinerjisi — trail
	if _check_speed_synergy():
		trail_timer -= delta
		if trail_timer <= 0:
			trail_timer = 0.3
			PlayerUiHelpers.spawn_speed_synergy_trail(self)
	
	# Koleksiyon Bonusu — 6 item = %1 HP/sn
	if active_items.size() >= 6:
		collection_regen_timer += delta
		if collection_regen_timer >= 1.0:
			collection_regen_timer = 0.0
			var regen = max(1, int(max_hp * 0.01))
			heal(regen)

func update_hp_bar():
	var ratio = float(hp) / float(max_hp)
	hp_bar_fill.size.x = 50 * ratio
	if ratio > 0.5:
		hp_bar_fill.color = Color("#2ECC71")
	elif ratio > 0.25:
		hp_bar_fill.color = Color("#F39C12")
	else:
		hp_bar_fill.color = Color("#E74C3C")

func update_category_ui():
	var labels = {
		"attack": attack_label,
		"defense": defense_label,
		"vampire": vampire_label,
		"utility": utility_label,
	}
	var names = {"attack": "⚔", "defense": "🛡", "vampire": "🩸", "utility": "⚡"}
	var colors = {
		"attack": Color("#E74C3C"),
		"defense": Color("#3498DB"),
		"vampire": Color("#9B59B6"),
		"utility": Color("#2ECC71"),
	}
	for cat in labels:
		var count = category_counts[cat]
		var label = labels[cat]
		if count == 0:
			label.visible = false
		else:
			label.visible = true
			label.add_theme_color_override("font_color", colors[cat])
			var stars = " ★★" if count >= 6 else (" ★" if count >= 3 else "")
			label.text = names[cat] + " " + str(count) + stars

func get_luck() -> float:
	return SaveManager.meta_upgrades["luck_bonus"] * 0.1

## Ayarlar → oynanış: oyuncu tarafı görsel efekt opaklığı (0–100%).
func get_player_vfx_opacity() -> float:
	return clampf(float(SaveManager.settings.get("player_vfx_opacity", 1.0)), 0.0, 1.0)

func get_cooldown_multiplier() -> float:
	var reduction = SaveManager.meta_upgrades.get("cooldown_bonus", 0) * 0.08
	return max(0.10, 1.0 - reduction + _origin_cooldown_bonus)

func get_area_multiplier() -> float:
	return 1.0 + SaveManager.meta_upgrades.get("area_bonus", 0) * 0.10 + _origin_area_bonus

func get_duration_multiplier() -> float:
	return 1.0 + SaveManager.meta_upgrades.get("duration_bonus", 0) * 0.15

func get_multi_attack_bonus() -> int:
	return SaveManager.meta_upgrades.get("multi_attack_bonus", 0)

func can_add_weapon() -> bool:
	return active_weapons.size() < max_weapons

func can_add_item() -> bool:
	return active_items.size() < max_items

func add_weapon(type: String):
	if active_weapons.has(type):
		active_weapons[type].upgrade()
		recalculate_category_bonus()
		return
	if not can_add_weapon():
		return

	var weapon: Node = PlayerLoadoutRegistry.create_weapon(type)

	if weapon:
		add_child(weapon)
		active_weapons[type] = weapon
		recalculate_category_bonus()
		SaveManager.register_codex_weapon(type)

func evolve_weapon(evo_id: String):
	if not WeaponEvolution.is_evolution_ready(self, evo_id):
		push_warning("evolve_weapon: requirements not met (%s)" % evo_id)
		return
	var evo = WeaponEvolution.EVOLUTIONS[evo_id]
	for w in evo["requires_weapons"]:
		if active_weapons.has(w):
			active_weapons[w].queue_free()
			active_weapons.erase(w)
	EventBus.hit_stop_requested.emit(4)
	add_weapon(evo_id)
	evolution_obtained = true
	var evo_name = WeaponEvolution.localized_name(evo_id)
	var float_fmt = tr("ui.upgrade_ui.evolution_floating")
	show_floating_text(float_fmt % evo_name, global_position + Vector2(0, -80), Color("#FFD700"))

func add_item(type: String):
	if active_items.has(type):
		active_items[type].upgrade()
		recalculate_category_bonus()
		return
	if not can_add_item():
		return

	var item: Node = PlayerLoadoutRegistry.create_item(type)

	if item:
		active_items[type] = item
		add_child(item)
		recalculate_category_bonus()
		SaveManager.register_codex_item(type)

func recalculate_category_bonus():
	category_counts = {"attack": 0, "defense": 0, "vampire": 0, "utility": 0}
	for w in active_weapons.values():
		if category_counts.has(w.category):
			category_counts[w.category] += w.level
	for i in active_items.values():
		if category_counts.has(i.category):
			category_counts[i.category] += i.level
	
	category_damage_bonus = 0
	category_crit_bonus = 0.0
	category_xp_bonus = 0.0
	category_speed_bonus = 0
	category_hp_bonus = 0
	
	for cat in category_counts:
		var bonus = CategoryBonus.get_bonus(cat, category_counts[cat])
		category_damage_bonus += bonus["damage"]
		category_crit_bonus += bonus["crit"]
		category_xp_bonus += bonus["xp"]
		category_speed_bonus += bonus["speed"]
		category_hp_bonus += bonus["hp"]
	
	if category_hp_bonus > 0:
		max_hp = 100 + category_hp_bonus
		hp = min(hp, max_hp)
		update_hp_bar()
	
	update_category_ui()

func get_total_damage(base_damage: int) -> int:
	# Adrenalin: can azaldıkça ateş hızı değil, hasar artar
	var adrenaline_rank = SaveManager.meta_upgrades.get("adrenaline", 0)
	var adrenaline_bonus = 0
	if adrenaline_rank > 0:
		var missing_hp_pct = 1.0 - (float(hp) / float(max_hp))
		adrenaline_bonus = int(missing_hp_pct * adrenaline_rank * 20)
	var turbine_bonus = 0
	if active_items.has("turbine"):
		turbine_bonus = active_items["turbine"].get_damage_bonus()
	var dmg = base_damage + bullet_damage + category_damage_bonus + momentum_bonus + adrenaline_bonus + turbine_bonus
	var crit_chance = category_crit_bonus + get_tag_crit_bonus()
	if active_items.has("crit"):
		crit_chance += active_items["crit"].crit_chance
	if active_items.has("luck_stone"):
		crit_chance += active_items["luck_stone"].get_crit_bonus()
	if randf() < crit_chance:
		var meta_crit = SaveManager.meta_upgrades.get("crit_damage_bonus", 0) * 0.25
		var crit_multiplier = 2.0 + meta_crit
		if active_items.has("crit"):
			crit_multiplier = active_items["crit"].crit_multiplier + meta_crit
		dmg = int(dmg * crit_multiplier)
		EventBus.hit_stop_requested.emit(2)
		show_floating_text(tr("ui.player.crit_floating"), global_position + Vector2(0, -70), Color("#FFD700"), 28)
	return dmg


func on_enemy_killed(enemy_position: Vector2):
	if active_items.has("explosion"):
		active_items["explosion"].on_enemy_killed(enemy_position)
	if active_items.has("blood_pool"):
		active_items["blood_pool"].on_enemy_killed(enemy_position)
	if active_items.has("speed_charm"):
		active_items["speed_charm"].on_enemy_killed(enemy_position)
	if active_items.has("ember_heart"):
		active_items["ember_heart"].on_enemy_killed(enemy_position)
	if active_weapons.has("storm"):
		active_weapons["storm"].on_enemy_killed_bonus()
	kill_count += 1
	# Boss öldürme kontrolü enemy_base üzerinden gelmiyor, EventBus ile yapacağız
	var now = Time.get_ticks_msec() / 1000.0
	recent_kill_times.append(now)
	while recent_kill_times.size() > 0 and now - recent_kill_times[0] > 1.2:
		recent_kill_times.remove_at(0)
	if recent_kill_times.size() >= 3:
		var combo = recent_kill_times.size()
		show_floating_text("COMBO x" + str(combo) + "!", enemy_position + Vector2(randf_range(-30, 30), -80), Color("#FF6B35"))
	EventBus.enemy_killed.emit(enemy_position)
	if SaveManager.game_mode != "local_coop":
		var kl: Node = get_node_or_null("CanvasLayer/StatsRow/KillLabel")
		if kl:
			kl.text = "💀 " + str(kill_count)

# YENİ — tank öldürme takibi için
func on_tank_killed():
	tank_killed = true

func heal(amount: int):
	var overheal_rank = SaveManager.meta_upgrades.get("overheal", 0)
	if overheal_rank > 0 and hp >= max_hp:
		overheal_shield = min(overheal_shield + amount, max_hp * overheal_rank / 5)
		show_floating_text("🛡+" + str(amount), global_position + Vector2(0, -50), Color("#00FFFF"))
		return
	hp = min(hp + amount, max_hp)
	update_hp_bar()
	EventBus.player_healed.emit(amount)
	show_floating_text("+" + str(amount), global_position + Vector2(0, -50), Color("#2ECC71"))

func show_floating_text(text: String, pos: Vector2, color: Color, font_size: int = 16):
	var popup = ObjectPool.get_object("res://effects/damage_number.tscn")
	popup.global_position = pos
	popup.show_damage_text(text, color, font_size)

func get_magnet_bonus() -> float:
	var bonus = SaveManager.meta_upgrades.get("magnet_bonus", 0) * 15.0
	if active_items.has("magnet"):
		bonus += active_items["magnet"].get_bonus_radius()
	if active_items.has("resonance_stone"):
		bonus += active_items["resonance_stone"].get_pickup_bonus()
	return bonus


func _format_loadout_level_step(translation_key: String, from_lv: int, to_lv: int) -> String:
	var tpl: String = tr(translation_key)
	if tpl == translation_key or tpl.is_empty():
		return "Lv " + str(from_lv) + " → " + str(to_lv)
	if tpl.contains("{0}") and tpl.contains("{1}"):
		return tpl.format([from_lv, to_lv])
	if tpl.count("%d") >= 2:
		return tpl % [from_lv, to_lv]
	return "Lv " + str(from_lv) + " → " + str(to_lv)


func get_weapon_description(type: String) -> String:
	if active_weapons.has(type):
		var w = active_weapons[type]
		if w.level >= w.max_level:
			return w.get_description() + tr("ui.player.loadout.max_suffix")
		var name_key := "codex.weapon.%s.name" % type
		var wname: String = tr(name_key)
		if wname == name_key or wname.is_empty():
			wname = str(w.get("weapon_name"))
		var step: String = _format_loadout_level_step("ui.player.loadout.level_step_weapon", w.level, w.level + 1)
		# get_description() içinde "%15" gibi diziler sprintf ile çakışmasın diye % kullanmıyoruz
		var cur: String = tr("ui.player.loadout.current_effect_prefix") + w.get_description()
		return wname + "\n" + step + "\n" + cur
	var name_key_new := "codex.weapon.%s.name" % type
	var wname_new := tr(name_key_new)
	if wname_new == name_key_new or wname_new.is_empty():
		wname_new = str(type).replace("_", " ").capitalize()
	var line: String = tr("ui.player.loadout.new_weapon_prefix") + wname_new
	var desc_key := "codex.weapon.%s.desc" % type
	var desc := tr(desc_key)
	if desc != desc_key and not desc.is_empty():
		line += "\n" + desc
	return line

func get_item_description(type: String) -> String:
	if active_items.has(type):
		var i = active_items[type]
		if i.level >= i.max_level:
			return i.get_description() + tr("ui.player.loadout.max_suffix")
		var name_key := "codex.item.%s.name" % type
		var iname: String = tr(name_key)
		if iname == name_key or iname.is_empty():
			iname = str(i.get("item_name"))
		var step: String = _format_loadout_level_step("ui.player.loadout.level_step_item", i.level, i.level + 1)
		var cur: String = tr("ui.player.loadout.current_effect_prefix") + i.get_description()
		return iname + "\n" + step + "\n" + cur
	var name_key_new := "codex.item.%s.name" % type
	var iname_new := tr(name_key_new)
	if iname_new == name_key_new or iname_new.is_empty():
		iname_new = str(type).replace("_", " ").capitalize()
	var line: String = tr("ui.player.loadout.new_item_prefix") + iname_new
	var desc_key := "codex.item.%s.desc" % type
	var desc := tr(desc_key)
	if desc != desc_key and not desc.is_empty():
		line += "\n" + desc
	return line

func gain_xp(amount: int):
	var curse_multiplier = 1.0 + SaveManager.meta_upgrades.get("curse_level", 0) * 1.0 + SaveManager.get_run_curse_tier() * 0.12
	var bonus = 1.0 + SaveManager.meta_upgrades["xp_bonus"] * 0.1 + category_xp_bonus + _origin_xp_bonus
	if shrine_active:
		bonus *= 3.0
	xp += int(amount * bonus * curse_multiplier)
	if SaveManager.game_mode != "local_coop":
		xp_bar.value = xp
	AudioManager.play_xp()
	EventBus.xp_gained.emit(amount)
	while xp >= xp_to_next_level:
		xp -= xp_to_next_level
		_apply_one_level_gain()

	if SaveManager.game_mode != "local_coop":
		xp_bar.max_value = xp_to_next_level
		xp_bar.value = xp

func _apply_one_level_gain() -> void:
	level += 1
	EventBus.player_leveled_up.emit(level)
	xp_to_next_level = _calc_xp_for_level(level)
	gold_earned += 3
	if SaveManager.game_mode != "local_coop":
		$CanvasLayer/StatsRow/GoldLabel.text = "💰 " + str(gold_earned)
	AudioManager.play_levelup()
	PlayerUiHelpers.spawn_levelup_effect(self)
	PlayerUiHelpers.spawn_levelup_screen_flash(self)
	var main = get_tree().get_first_node_in_group("main")
	if main and main.has_method("queue_upgrade"):
		main.queue_upgrade(self)

func _on_stats_button_pressed() -> void:
	PlayerUiHelpers.toggle_stats_panel(self)

func _on_upgrade_chosen(upgrade_id: String):
	if upgrade_id == "skip":
		if upgrade_ui:
			upgrade_ui.queue_free()
			upgrade_ui = null
		return

	if upgrade_id in WeaponEvolution.EVOLUTIONS:
		evolve_weapon(upgrade_id)
	elif upgrade_id in _LEVELUP_WEAPON_IDS:
		add_weapon(upgrade_id)
	elif upgrade_id in _LEVELUP_ITEM_IDS:
		add_item(upgrade_id)
	else:
		match upgrade_id:
			"speed":
				SPEED = minf(SPEED + 20.0, MAX_MOVE_SPEED)
			"max_hp":
				max_hp += 25
				hp = min(hp + 25, max_hp)
				update_hp_bar()
			"heal":
				heal(20)

	if upgrade_ui:
		upgrade_ui.queue_free()
		upgrade_ui = null

func get_nearest_enemy():
	var enemies = EnemyRegistry.get_enemies()
	var nearest = null
	var nearest_dist = 999999.0
	for enemy in enemies:
		var dist = global_position.distance_to(enemy.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = enemy
	return nearest

func take_damage(amount: int):
	# Buharlı Zırh aktifse hasar alma
	if active_items.has("steam_armor") and active_items["steam_armor"].is_invincible():
		return
	var armor = SaveManager.meta_upgrades.get("armor_bonus", 0) * 2 + _origin_armor_bonus
	if active_items.has("armor"):
		armor += active_items["armor"].armor_value
	if active_items.has("glyph_charm"):
		armor += active_items["glyph_charm"].ward_value
	if active_items.has("rampart_plate"):
		armor += active_items["rampart_plate"].armor_value
	if active_items.has("iron_bulwark"):
		armor += active_items["iron_bulwark"].armor_value
	var final_damage = max(1, amount - armor)
	if overheal_shield > 0:
		var absorbed = min(overheal_shield, final_damage)
		overheal_shield -= absorbed
		final_damage -= absorbed
		if final_damage <= 0:
			return
	if active_items.has("shield"):
		final_damage = active_items["shield"].absorb_damage(final_damage)
	if final_damage <= 0:
		return
	hp -= final_damage
	update_hp_bar()
	# Buharlı Zırh tetikle
	if active_items.has("steam_armor"):
		active_items["steam_armor"].on_player_damaged()
	AudioManager.play_player_hurt()
	_flash_damage()
	EventBus.player_damaged.emit(final_damage)
	var dmg_setting = SaveManager.settings.get("damage_numbers", "both_on")
	if dmg_setting == "both_on" or dmg_setting == "player_only":
		var popup = ObjectPool.get_object("res://effects/damage_number.tscn")
		popup.global_position = global_position + Vector2(0, -40)
		popup.show_damage_text("-" + str(final_damage), Color("#E74C3C"))
	if hp <= 0:
		die()

func die():
	if not revival_used and SaveManager.meta_upgrades.get("revival", 0) >= 1:
		revival_used = true
		hp = int(max_hp * 0.3)
		update_hp_bar()
		show_floating_text("✨ REVIVAL!", global_position + Vector2(0, -80), Color("#FFD700"))
		return

	# Co-op ölüm sistemi
	if SaveManager.game_mode == "local_coop":
		_enter_downed_state()
		return

	# Solo ölüm
	_solo_die()

func _enter_downed_state():
	is_downed = true
	hp = 0
	update_hp_bar()
	# Hareketi durdur
	set_physics_process(false)
	# Görsel — transparan yap
	if body:
		var tween = body.create_tween()
		tween.tween_property(body, "modulate:a", 0.3 * get_player_vfx_opacity(), 0.5)
	show_floating_text("💀 KNO DOWN!", global_position + Vector2(0, -60), Color("#FF0000"), 20)
	# Canlandırma alanı oluştur
	_setup_revive_area()
	# Tüm oyuncular düştü mü kontrol et
	await get_tree().create_timer(0.5).timeout
	_check_all_downed()

func _setup_revive_area():
	var area = Area2D.new()
	area.name = "ReviveArea"
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 60.0
	shape.shape = circle
	area.add_child(shape)
	add_child(area)
	area.body_entered.connect(_on_reviver_entered)

func _on_reviver_entered(body: Node):
	if not is_downed:
		return
	if body.is_in_group("player") and body != self:
		revive()

func revive():
	is_downed = false
	hp = int(max_hp * 0.3)
	set_physics_process(true)
	if body:
		var tween = body.create_tween()
		tween.tween_property(body, "modulate:a", 1.0, 0.3)
	update_hp_bar()
	var revive_area = get_node_or_null("ReviveArea")
	if revive_area:
		revive_area.queue_free()
	show_floating_text("✨ CANLANDIRILD!", global_position + Vector2(0, -60), Color("#00FF00"), 20)

func _check_all_downed():
	var players = get_tree().get_nodes_in_group("player")
	var all_downed = true
	for p in players:
		if not p.is_downed:
			all_downed = false
			break
	if all_downed:
		_solo_die()

func _solo_die():
	var player_count = get_tree().get_nodes_in_group("player").size()
	SaveManager.add_gold(int(gold_earned / max(1, player_count)))
	var char_id: String = SaveManager.get_character_id_for_player(player_id)
	var game_time = get_tree().get_first_node_in_group("main").game_timer
	var won = game_time >= SaveManager.get_run_goal_sec()
	SaveManager.update_stats_after_game(char_id, kill_count, game_time, evolution_obtained, tank_killed, gold_earned, level - 1, boss_kill_count, total_damage_dealt, chests_opened, active_items.size(), won)
	AchievementManager.check_after_game(kill_count, game_time)
	EventBus.player_died.emit()
	call_deferred("_deferred_die")

func _deferred_die():
	var game_time = get_tree().get_first_node_in_group("main").game_timer
	get_tree().paused = true
	var go = game_over_scene.instantiate()
	go.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child(go)
	var won = game_time >= SaveManager.get_run_goal_sec()
	go.show_stats(game_time, level, kill_count, gold_earned, won)

func collect_gold(amount: int):
	var final_amount = amount * (3 if shrine_active else 1)
	gold_earned += final_amount
	amount = final_amount
	if SaveManager.game_mode != "local_coop":
		$CanvasLayer/StatsRow/GoldLabel.text = "💰 " + str(gold_earned)
	EventBus.gold_collected.emit(final_amount)
	show_floating_text("+" + str(amount) + "💰", global_position + Vector2(randf_range(-20, 20), -50), Color("#FFD700"))
	
func _flash_damage():
	var tween = body.create_tween()
	tween.tween_property(body, "color", Color.WHITE, 0.04)
	tween.tween_property(body, "color", _body_base_color, 0.12)

func _on_player_damaged(amount: int):
	if not SaveManager.settings.get("screen_shake", true):
		return
	shake_intensity = min(amount * 0.3, 8.0)
	shake_duration = 0.25

func _on_boss_spawned():
	if not SaveManager.settings.get("screen_shake", true):
		return
	shake_intensity = 14.0
	shake_duration = 0.7

func _update_screen_shake(delta: float):
	if shake_duration > 0:
		shake_duration -= delta
		var main = get_tree().get_first_node_in_group("main")
		if main and main.main_camera:
			var offset = Vector2(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity))
			main.main_camera.offset = offset
			if shake_duration <= 0:
				main.main_camera.offset = Vector2.ZERO
				shake_intensity = 0.0



func _calc_xp_for_level(lvl: int) -> int:
	if lvl <= 5:
		return 18 + lvl * 8
	if lvl <= 20:
		return 30 + lvl * 10
	elif lvl <= 40:
		return 230 + (lvl - 20) * 13
	else:
		return 490 + (lvl - 40) * 16

func _check_speed_synergy() -> bool:
	# MoveSpeed ve speed_charm ikisi de max level mi?
	var has_speed_charm_max = active_items.has("speed_charm") and active_items["speed_charm"].level >= active_items["speed_charm"].max_level
	var speed_bonus = SaveManager.meta_upgrades.get("speed_bonus", 0)
	return has_speed_charm_max and speed_bonus >= 5

func get_weapon_tag_counts() -> Dictionary:
	var counts = {"kesici": 0, "patlayici": 0, "buyu": 0, "teknolojik": 0}
	for w in active_weapons.values():
		if counts.has(w.tag):
			counts[w.tag] += 1
	return counts

func get_tag_crit_bonus() -> float:
	var counts = get_weapon_tag_counts()
	var bonus = 0.0
	for tag_id in counts:
		var c = counts[tag_id]
		if c >= 6:
			bonus += 0.30
		elif c >= 3:
			bonus += 0.10
	return bonus


var _stat_panel = null


func _setup_player_visuals():
	# Gelecekte Sprite2D animasyonları buradan yönetilecek
	if body:
		body.name = "Body"

func _setup_input():
	# Şimdilik tek oyuncu — ileride player_id'ye göre input mapping yapılacak
	pass
func set_player_id(id: int):
	player_id = id


func can_collect_more_cog_shards() -> bool:
	return cog_shard_count < 5


func apply_empty_level_reward() -> void:
	heal(20)
	var gold_amt: int = 25 * (3 if shrine_active else 1)
	gold_earned += gold_amt
	EventBus.gold_collected.emit(gold_amt)
	if SaveManager.game_mode != "local_coop":
		var gl := get_node_or_null("CanvasLayer/StatsRow/GoldLabel")
		if gl:
			gl.text = "💰 " + str(gold_earned)
	show_floating_text(tr("ui.player.empty_level_reward"), global_position + Vector2(0, -88), Color("#FFD700"), 18)
	AudioManager.play_levelup()


func _update_cog_label() -> void:
	var cog_label := get_node_or_null("CanvasLayer/StatsRow/CogLabel")
	if cog_label == null:
		return
	cog_label.text = "⚙ " + str(cog_shard_count) + "/5"
	if cog_shard_count >= 5:
		cog_label.add_theme_color_override("font_color", Color("#FFD700"))
	else:
		cog_label.remove_theme_color_override("font_color")


func collect_cog_shard() -> bool:
	if cog_shard_count >= 5:
		return false
	cog_shard_count += 1
	show_floating_text(
		"⚙ " + str(cog_shard_count) + "/5",
		global_position + Vector2(randf_range(-20, 20), -60),
		Color("#B0C4DE"), 16
	)
	_update_cog_label()
	if cog_shard_count >= 5:
		cog_shard_bonus_active = true
		show_floating_text(
			tr("ui.player.cog_master_ready"),
			global_position + Vector2(0, -80),
			Color("#00FFFF"), 22
		)
	return true
func activate_blood_oath():
	blood_oath_active = true
	blood_oath_timer = BLOOD_OATH_DURATION
	show_floating_text(
		"🩸 KAN YEMİNİ! 30sn",
		global_position + Vector2(0, -80),
		Color("#FF0000"), 20
	)
