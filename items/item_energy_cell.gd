class_name ItemEnergyCell
extends PassiveItem

var charge_timer = 0.0
var discharge_timer = 0.0
var charge_interval = 20.0
var discharge_duration = 3.0
var is_discharged = false

func _ready():
	item_name = "Enerji Hücresi"
	description = "Periyodik olarak tüm silahları anında ateşler, sonra kısa mola"
	category = "utility"
	max_level = 5
	super._ready()

func apply():
	charge_interval = 20.0 - (level - 1) * 3.0
	discharge_duration = 3.0 - (level - 1) * 0.4

func _process(delta):
	if is_discharged:
		discharge_timer -= delta
		if discharge_timer <= 0:
			is_discharged = false
			_restore_weapons()
	else:
		charge_timer += delta
		if charge_timer >= charge_interval:
			charge_timer = 0.0
			_trigger_discharge()

func _trigger_discharge():
	if player == null:
		return
	is_discharged = true
	discharge_timer = discharge_duration
	# Tüm silahların timer'ını sıfırla — hepsi hemen ateşlesin
	for w in player.active_weapons.values():
		if w.get("timer") != null:
			w.timer = 0.0
	player.show_floating_text(
		"⚡ ENERJİ BOŞALIMI!",
		player.global_position + Vector2(0, -80),
		Color("#FFD700"), 20
	)
	# Deşarj süresinde silahları yavaşlat
	for w in player.active_weapons.values():
		if w.get("cooldown") != null:
			w.set_meta("pre_discharge_cooldown", w.cooldown)
			w.cooldown *= 3.0

func _restore_weapons():
	if player == null:
		return
	for w in player.active_weapons.values():
		if w.has_meta("pre_discharge_cooldown"):
			w.cooldown = w.get_meta("pre_discharge_cooldown")
			w.remove_meta("pre_discharge_cooldown")
	player.show_floating_text(
		"⚡ Şarj oluyor...",
		player.global_position + Vector2(0, -60),
		Color("#AAAAAA"), 14
	)

func get_description() -> String:
	return "Enerji Hücresi Lv" + str(level) + "\nHer " + str(charge_interval) + "sn ateş + " + str(discharge_duration) + "sn yavaş"
