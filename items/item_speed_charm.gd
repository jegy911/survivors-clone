class_name ItemSpeedCharm
extends PassiveItem

var speed_bonus = 20
var speed_duration = 2.0
var is_boosted = false
var boost_timer = 0.0

func _ready():
	item_name = "Hız Tılsımı"
	description = "Öldürünce geçici hız bonusu"
	category = "utility"
	max_level = 5
	super._ready()

func apply():
	speed_bonus = 20 + (level - 1) * 10
	speed_duration = 2.0 + (level - 1) * 0.2

func _process(delta):
	if is_boosted:
		boost_timer -= delta
		if boost_timer <= 0:
			is_boosted = false
			player.SPEED -= speed_bonus

func on_enemy_killed(_position: Vector2):
	if not is_boosted:
		is_boosted = true
		boost_timer = speed_duration
		player.SPEED += speed_bonus
		player.show_floating_text("HIZLI!", player.global_position + Vector2(0, -70), Color("#2ECC71"))
	else:
		boost_timer = speed_duration

func get_description() -> String:
	return tr("ui.upgrade_ui.stats.loadout_items.speed_charm") % [
		level,
		speed_bonus,
		snappedf(speed_duration, 0.1),
	]
