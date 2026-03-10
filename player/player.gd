extends CharacterBody2D

var BASE_SPEED = 130.0
var SPEED = 130.0
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

func _ready_damage_tracking():
	EventBus.on_damage_dealt.connect(_on_damage_tracked)

func _on_damage_tracked(p: Node, _enemy: Node, damage: int):
	if p == self:
		total_damage_dealt += damage

# Revival
var revival_used = false
var tank_killed = false        # YENİ
var evolution_obtained = false # YENİ

# Pasif iyileşme sayacı
var recovery_timer = 0.0

# Combo / kill streak
var recent_kill_times: Array = []

var upgrade_ui_scene = preload("res://ui/upgrade_ui.tscn")
var game_over_scene = preload("res://ui/game_over.tscn")
var pause_menu_scene = preload("res://ui/pause_menu.tscn")
var upgrade_ui = null
var pause_menu = null

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
	
	xp_bar.max_value = xp_to_next_level
	xp_bar.min_value = 0
	xp_bar.value = 0
	xp_bar.show_percentage = false
	
	update_hp_bar()
	update_category_ui()
	EventBus.player_damaged.connect(_on_player_damaged)
	EventBus.boss_spawned.connect(_on_boss_spawned)
	_ready_damage_tracking()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if get_tree().paused:
			if pause_menu:
				pause_menu.queue_free()
				pause_menu = null
			get_tree().paused = false
		else:
			get_tree().paused = true
			pause_menu = pause_menu_scene.instantiate()
			pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS
			get_tree().root.add_child(pause_menu)

func apply_character_bonuses():
	var char_data = CharacterData.CHARACTERS[SaveManager.selected_character]
	_body_base_color = Color(char_data["color"])
	body.color = _body_base_color
	bullet_damage += char_data["bonus_damage"]
	max_hp += char_data["bonus_hp"]
	hp = max_hp
	SPEED += char_data["bonus_speed"]
	if not active_weapons.has(char_data["start_weapon"]):
		add_weapon(char_data["start_weapon"])
	if char_data["start_item"] != "":
		add_item(char_data["start_item"])
	var special = char_data.get("special", "")
	if special == "all_weapons_1hp":
		max_hp = 1
		hp = 1
	elif special == "damage_double":
		bullet_damage *= 2

func apply_meta_bonuses():
	var meta = SaveManager.meta_upgrades
	
	# Mevcut bonuslar
	max_hp += meta["max_hp_bonus"] * 25
	hp = max_hp
	bullet_damage += meta["damage_bonus"] * 5
	SPEED += meta["speed_bonus"] * 10
	
	# Başlangıç zırhı — take_damage'de kullanılıyor
	# (armor_bonus direkt orada okunuyor)
	
	# Başlangıç seviyesi
	for i in meta["start_level_bonus"]:
		level += 1
		xp_to_next_level = int(xp_to_next_level * 1.3)
	
	# Revival — oyun başında sıfırla
	revival_used = false

func _physics_process(delta):
	var direction = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	velocity = direction.normalized() * SPEED
	move_and_slide()

func _process(delta):
	# Pasif can yenileme — her dakika recovery_bonus * 3 HP
	var recovery = SaveManager.meta_upgrades.get("recovery_bonus", 0)
	if recovery > 0:
		recovery_timer += delta
		if recovery_timer >= 60.0:
			recovery_timer = 0.0
			heal(recovery * 3)
	_update_screen_shake(delta)

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

func get_cooldown_multiplier() -> float:
	return 1.0 - SaveManager.meta_upgrades.get("cooldown_bonus", 0) * 0.08

func get_area_multiplier() -> float:
	return 1.0 + SaveManager.meta_upgrades.get("area_bonus", 0) * 0.10

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
	
	var weapon = null
	match type:
		"bullet":
			weapon = WeaponBullet.new()
		"aura":
			weapon = WeaponAura.new()
		"chain":
			weapon = WeaponChain.new()
		"boomerang":
			weapon = WeaponBoomerang.new()
		"lightning":
			weapon = WeaponLightning.new()
		"ice_ball":
			weapon = WeaponIceBall.new()
		"shadow":
			weapon = WeaponShadow.new()
		"laser":
			weapon = WeaponLaser.new()
		"holy_bullet":
			weapon = WeaponHolyBullet.new()
		"toxic_chain":
			weapon = WeaponToxicChain.new()
		"death_laser":
			weapon = WeaponDeathLaser.new()
		"blood_boomerang":
			weapon = WeaponBloodBoomerang.new()
		"storm":
			weapon = WeaponStorm.new()
	
	if weapon:
		add_child(weapon)
		active_weapons[type] = weapon
		recalculate_category_bonus()

func evolve_weapon(evo_id: String):
	var evo = WeaponEvolution.EVOLUTIONS[evo_id]
	for w in evo["requires_weapons"]:
		if active_weapons.has(w):
			active_weapons[w].queue_free()
			active_weapons.erase(w)
	EventBus.hit_stop_requested.emit(4)
	add_weapon(evo_id)
	evolution_obtained = true
	show_floating_text("⚡ EVRİM: " + evo["name"] + "!", global_position + Vector2(0, -80), Color("#FFD700"))

func add_item(type: String):
	if active_items.has(type):
		active_items[type].upgrade()
		recalculate_category_bonus()
		return
	if not can_add_item():
		return
	
	var item = null
	match type:
		"lifesteal":
			item = ItemLifesteal.new()
		"armor":
			item = ItemArmor.new()
		"crit":
			item = ItemCrit.new()
		"explosion":
			item = ItemExplosion.new()
		"magnet":
			item = ItemMagnet.new()
		"poison":
			item = ItemPoison.new()
		"shield":
			item = ItemShield.new()
		"speed_charm":
			item = ItemSpeedCharm.new()
		"blood_pool":
			item = ItemBloodPool.new()
		"luck_stone":
			item = ItemLuckStone.new()
	
	if item:
		add_child(item)
		active_items[type] = item
		recalculate_category_bonus()

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
	var dmg = base_damage + category_damage_bonus
	var crit_chance = category_crit_bonus
	if active_items.has("crit"):
		crit_chance += active_items["crit"].crit_chance
	if randf() < crit_chance:
		# Kritik çarpanı: 2.0 + crit_damage_bonus * 0.25
		var crit_multiplier = 2.0 + SaveManager.meta_upgrades.get("crit_damage_bonus", 0) * 0.25
		dmg = int(dmg * crit_multiplier)
		EventBus.hit_stop_requested.emit(2)
		show_floating_text("KRİTİK!", global_position + Vector2(0, -70), Color("#FFD700"), 28)
	return dmg

func on_damage_dealt(damage: int, _enemy_position: Vector2):
	if active_items.has("lifesteal"):
		active_items["lifesteal"].on_damage_dealt(damage)
	if active_items.has("poison"):
		active_items["poison"].on_damage_dealt(damage)

func on_enemy_killed(enemy_position: Vector2):
	if active_items.has("explosion"):
		active_items["explosion"].on_enemy_killed(enemy_position)
	if active_items.has("blood_pool"):
		active_items["blood_pool"].on_enemy_killed(enemy_position)
	if active_items.has("speed_charm"):
		active_items["speed_charm"].on_enemy_killed(enemy_position)
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
	$CanvasLayer/StatsRow/KillLabel.text = "💀 " + str(kill_count)

# YENİ — tank öldürme takibi için
func on_tank_killed():
	tank_killed = true

func heal(amount: int):
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
	return bonus

func get_weapon_description(type: String) -> String:
	if active_weapons.has(type):
		var w = active_weapons[type]
		if w.level >= w.max_level:
			return w.get_description() + " (MAX)"
		return w.get_description() + " → Lv" + str(w.level + 1)
	match type:
		"bullet": return "Yeni Silah: Mermi"
		"aura": return "Yeni Silah: Aura"
		"chain": return "Yeni Silah: Zincir"
		"boomerang": return "Yeni Silah: Bumerang"
		"lightning": return "Yeni Silah: Yıldırım"
		"ice_ball": return "Yeni Silah: Buz Topu"
		"shadow": return "Yeni Silah: Gölge"
		"laser": return "Yeni Silah: Lazer"
	return ""

func get_item_description(type: String) -> String:
	if active_items.has(type):
		var i = active_items[type]
		if i.level >= i.max_level:
			return i.get_description() + " (MAX)"
		return i.get_description() + " → Lv" + str(i.level + 1)
	match type:
		"lifesteal": return "Yeni: Can Çalma\nHer vuruşta hasar → HP"
		"armor": return "Yeni: Zırh\nAlınan hasarı azaltır"
		"crit": return "Yeni: Kritik Vuruş\nŞans ile 2x hasar"
		"explosion": return "Yeni: Patlama\nDüşman ölünce alan hasarı"
		"magnet": return "Yeni: Mıknatıs\nXP çekim menzili artar"
		"poison": return "Yeni: Zehir\nVuruşta zehir uygular"
		"shield": return "Yeni: Kalkan\nHasar absorbe eder"
		"speed_charm": return "Yeni: Hız Tılsımı\nÖldürünce hız bonusu"
		"blood_pool": return "Yeni: Kan Havuzu\nÖldürünce alan hasarı"
		"luck_stone": return "Yeni: Şans Taşı\nKritik şansı + altın"
	return ""

func gain_xp(amount: int):
	var curse_multiplier = 1.0 + SaveManager.meta_upgrades.get("curse_level", 0) * 1.0
	var bonus = 1.0 + SaveManager.meta_upgrades["xp_bonus"] * 0.1 + category_xp_bonus
	xp += int(amount * bonus * curse_multiplier)
	xp_bar.value = xp
	AudioManager.play_xp()
	EventBus.xp_gained.emit(amount)
	if xp >= xp_to_next_level:
		level_up()

func level_up():
	level += 1
	EventBus.player_leveled_up.emit(level)
	xp = 0
	xp_to_next_level = int(xp_to_next_level * 1.3)
	xp_bar.max_value = xp_to_next_level
	xp_bar.value = 0
	gold_earned += 3
	$CanvasLayer/StatsRow/GoldLabel.text = "💰 " + str(gold_earned)
	AudioManager.play_levelup()
	_spawn_levelup_effect()
	_spawn_levelup_screen_flash()
	get_tree().paused = true
	upgrade_ui = upgrade_ui_scene.instantiate()
	upgrade_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child(upgrade_ui)
	upgrade_ui.upgrade_chosen.connect(_on_upgrade_chosen)
	upgrade_ui.show_upgrades(self)

func _spawn_levelup_effect():
	for i in 5:
		var ring = ColorRect.new()
		ring.size = Vector2(30, 30)
		ring.color = Color("#FFD700")
		ring.position = global_position - Vector2(15, 15)
		get_parent().add_child(ring)
		var tween = ring.create_tween()
		var target_size = Vector2(180 + i * 80, 180 + i * 80)
		var target_pos = global_position - target_size / 2
		tween.set_parallel(true)
		tween.tween_property(ring, "size", target_size, 0.35 + i * 0.08)
		tween.tween_property(ring, "position", target_pos, 0.35 + i * 0.08)
		tween.tween_property(ring, "modulate:a", 0.0, 0.35 + i * 0.08)
		tween.set_parallel(false)
		tween.tween_callback(ring.queue_free)

func _spawn_levelup_screen_flash():
	var flash = ColorRect.new()
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash.color = Color.WHITE
	flash.modulate = Color(1, 1, 1, 0)
	flash.z_index = 100
	var vp_size = get_viewport().get_visible_rect().size
	flash.size = vp_size * 2
	flash.position = -vp_size / 2
	var layer = CanvasLayer.new()
	layer.layer = 100
	layer.add_child(flash)
	get_tree().root.add_child(layer)
	var tween = flash.create_tween()
	tween.tween_property(flash, "modulate", Color(1, 1, 1, 0.7), 0.06)
	tween.tween_property(flash, "modulate", Color(1, 1, 1, 0), 0.4)
	tween.tween_callback(layer.queue_free)

func _on_upgrade_chosen(upgrade_id: String):
	if upgrade_id == "skip":
		if upgrade_ui:
			upgrade_ui.queue_free()
			upgrade_ui = null
		get_tree().paused = false
		return
	
	if upgrade_id in WeaponEvolution.EVOLUTIONS:
		evolve_weapon(upgrade_id)
	else:
		match upgrade_id:
			"speed":
				SPEED += 20
			"max_hp":
				max_hp += 25
				hp = min(hp + 25, max_hp)
				update_hp_bar()
			"heal":
				heal(20)
			"bullet", "aura", "chain", "boomerang", "lightning", "ice_ball", "shadow", "laser":
				add_weapon(upgrade_id)
			"lifesteal", "armor", "crit", "explosion", "magnet", "poison", "shield", "speed_charm", "blood_pool", "luck_stone":
				add_item(upgrade_id)
	
	if upgrade_ui:
		upgrade_ui.queue_free()
		upgrade_ui = null
	get_tree().paused = false

func get_nearest_enemy():
	var enemies = get_tree().get_nodes_in_group("enemies")
	var nearest = null
	var nearest_dist = 999999.0
	for enemy in enemies:
		var dist = global_position.distance_to(enemy.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = enemy
	return nearest

func take_damage(amount: int):
	var armor = SaveManager.meta_upgrades.get("armor_bonus", 0) * 2
	if active_items.has("armor"):
		armor += active_items["armor"].armor_value
	var final_damage = max(1, amount - armor)
	if active_items.has("shield"):
		final_damage = active_items["shield"].absorb_damage(final_damage)
	if final_damage <= 0:
		return
	hp -= final_damage
	update_hp_bar()
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
	
	SaveManager.add_gold(gold_earned)
	var char_id = CharacterData.CHARACTERS[SaveManager.selected_character]["id"]
	var game_time = get_tree().get_first_node_in_group("main").game_timer
	SaveManager.update_stats_after_game(char_id, kill_count, game_time, evolution_obtained, tank_killed, gold_earned, level - 1, boss_kill_count, total_damage_dealt, chests_opened, active_items.size())
	EventBus.player_died.emit()
	call_deferred("_deferred_die")

func _deferred_die():
	var game_time = get_tree().get_first_node_in_group("main").game_timer
	get_tree().paused = true
	var go = game_over_scene.instantiate()
	go.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child(go)
	go.show_stats(game_time, level, kill_count, gold_earned)

func collect_gold(amount: int):
	gold_earned += amount
	$CanvasLayer/StatsRow/GoldLabel.text = "💰 " + str(gold_earned)
	EventBus.gold_collected.emit(amount)
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
		var offset = Vector2(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity))
		$Camera2D.offset = offset
		if shake_duration <= 0:
			$Camera2D.offset = Vector2.ZERO
			shake_intensity = 0.0

func recalculate_category_bonuses():
	var base_hp = 100
	base_hp += SaveManager.meta_upgrades["max_hp_bonus"] * 25
	base_hp += CharacterData.CHARACTERS[SaveManager.selected_character]["bonus_hp"]
	
	category_hp_bonus = 0
	category_damage_bonus = 0
	category_crit_bonus = 0.0
	category_speed_bonus = 0
	category_xp_bonus = 0.0
	
	for cat in category_counts:
		var bonus = CategoryBonus.get_bonus(cat, category_counts[cat])
		category_hp_bonus += bonus["hp"]
		category_damage_bonus += bonus["damage"]
		category_crit_bonus += bonus["crit"]
		category_speed_bonus += bonus["speed"]
		category_xp_bonus += bonus["xp"]
	
	max_hp = base_hp + category_hp_bonus
	hp = min(hp, max_hp)
	update_hp_bar()
