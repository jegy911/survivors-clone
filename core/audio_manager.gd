extends Node

@onready var shoot_player = $ShootPlayer
@onready var hit_player = $HitPlayer
@onready var death_player = $DeathPlayer
@onready var levelup_player = $LevelUpPlayer
@onready var player_hurt_player = $PlayerHurtPlayer
@onready var xp_player = $XPPlayer
@onready var boss_player = $BossPlayer

func _ready():
	apply_volume_settings()

func apply_volume_settings():
	var master = SaveManager.settings.get("master_volume", 1.0)
	var sfx = SaveManager.settings.get("sfx_volume", 1.0)
	var music = SaveManager.settings.get("music_volume", 1.0)
	
	AudioServer.set_bus_volume_db(0, linear_to_db(master))
	
	var sfx_bus = AudioServer.get_bus_index("SFX")
	if sfx_bus >= 0:
		AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(sfx))
	
	var music_bus = AudioServer.get_bus_index("Music")
	if music_bus >= 0:
		AudioServer.set_bus_volume_db(music_bus, linear_to_db(music))

func play_shoot():
	shoot_player.play()

func play_hit():
	hit_player.play()

func play_death():
	death_player.play()

func play_levelup():
	levelup_player.play()

func play_player_hurt():
	player_hurt_player.play()

func play_xp():
	xp_player.play()

func play_boss():
	boss_player.play()
