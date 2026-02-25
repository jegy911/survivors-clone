class_name ItemShield
extends PassiveItem

var shield_amount = 20
var shield_cooldown = 5.0
var shield_timer = 0.0
var shield_active = false

func _ready():
	item_name = "Kalkan"
	description = "Belirli aralıklarla hasar absorbe eder"
	category = "defense"
	max_level = 5
	super._ready()

func apply():
	shield_amount = 20 + (level - 1) * 10
	shield_cooldown = 5.0 - (level - 1) * 0.5

func _process(delta):
	if not shield_active:
		shield_timer += delta
		if shield_timer >= shield_cooldown:
			shield_timer = 0.0
			shield_active = true
			player.show_floating_text("🛡", player.global_position + Vector2(0, -70), Color("#3498DB"))

func absorb_damage(amount: int) -> int:
	if shield_active:
		shield_active = false
		shield_timer = 0.0
		player.show_floating_text("BLOK!", player.global_position + Vector2(0, -70), Color("#3498DB"))
		return 0
	return amount

func get_description() -> String:
	return "Kalkan Lv" + str(level) + "\n" + str(shield_amount) + " hasar absorbe | " + str(shield_cooldown) + "sn"
