class_name WeaponVoidLens
extends WeaponBase

const TEX_PULSE := preload("res://assets/projectiles/void_lens/void_lens_projectile.png")
const CATA_RADIUS_PX: float = 800.0
## Lv1 30 sn; her seviye −2.5 sn.
const CATA_INTERVAL_LV1_SEC: float = 30.0
const CATA_INTERVAL_PER_LEVEL_SEC: float = 2.5

var _time_until_cataclysm: float = 0.0
var _pulse_busy: bool = false

func _ready() -> void:
	super._ready()
	weapon_name = "Uçurum Merceği"
	tag = "buyu"
	category = "utility"
	damage = 0
	cooldown = 999.0
	_time_until_cataclysm = get_cataclysm_interval_sec()


func get_cataclysm_interval_sec() -> float:
	return maxf(3.0, CATA_INTERVAL_LV1_SEC - float(level - 1) * CATA_INTERVAL_PER_LEVEL_SEC)


func get_cataclysm_radius_px() -> float:
	return CATA_RADIUS_PX


func _process(delta: float) -> void:
	super._process(delta)
	if player == null or not is_instance_valid(player):
		return
	if _pulse_busy:
		return
	_time_until_cataclysm -= delta
	if _time_until_cataclysm <= 0.0:
		_pulse_busy = true
		var center: Vector2 = CenterCataclysmHelper.screen_center_global(player)
		CenterCataclysmHelper.spawn_grow_pulse(
			self, player, TEX_PULSE, center, get_cataclysm_radius_px(), 0.22, 1.08, 0.42
		)


func _on_cataclysm_pulse_finished() -> void:
	_pulse_busy = false
	_time_until_cataclysm = get_cataclysm_interval_sec()


func has_targets_for_attack() -> bool:
	return false


func attack() -> void:
	pass


func on_upgrade() -> void:
	_time_until_cataclysm = get_cataclysm_interval_sec()


func get_description() -> String:
	return tr("ui.upgrade_ui.stats.loadout_weapons.void_lens") % [
		level,
		int(get_cataclysm_radius_px()),
		get_cataclysm_interval_sec(),
	]
