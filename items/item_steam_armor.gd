class_name ItemSteamArmor
extends PassiveItem

var invincible = false
var invincible_timer = 0.0
var cooldown_timer = 0.0
var invincible_duration = 0.8
var invincible_cooldown = 8.0

func _ready():
	item_name = "Buharlı Zırh"
	description = "Hasar alınca kısa süre yenilmez olursun"
	category = "defense"
	max_level = 5
	super._ready()

func apply():
	invincible_duration = 0.5 + (level - 1) * 0.1
	invincible_cooldown = 10.0 - (level - 1) * 1.0

func _process(delta):
	if invincible:
		invincible_timer -= delta
		if invincible_timer <= 0:
			invincible = false
			if player and player.get_node_or_null("Body"):
				player.get_node("Body").modulate = Color(1, 1, 1, 1)
	if cooldown_timer > 0:
		cooldown_timer -= delta

func on_player_damaged():
	if invincible or cooldown_timer > 0:
		return
	invincible = true
	invincible_timer = invincible_duration
	cooldown_timer = invincible_cooldown
	if player:
		player.show_floating_text(
			"💨 BUHAR KALKANI!",
			player.global_position + Vector2(0, -70),
			Color("#00BFFF"), 16
		)
		if player.get_node_or_null("Body"):
			var a = 0.7 * player.get_player_vfx_opacity()
			player.get_node("Body").modulate = Color(0.5, 0.8, 1.0, a)

func is_invincible() -> bool:
	return invincible

func get_description() -> String:
	return tr("ui.upgrade_ui.stats.loadout_items.steam_armor") % [
		level,
		snappedf(invincible_duration, 0.1),
		snappedf(invincible_cooldown, 0.1),
	]
