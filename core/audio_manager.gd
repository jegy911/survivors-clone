extends Node

var xp_note_index = 0
var xp_note_timer = 0.0
var xp_streak: int = 0
var xp_notes = [0, 2, 4, 5, 7, 9, 11, 12] # Do Re Mi Fa Sol La Si Do

@onready var shoot_player = $ShootPlayer
@onready var hit_player = $HitPlayer
@onready var death_player = $DeathPlayer
@onready var levelup_player = $LevelUpPlayer
@onready var player_hurt_player = $PlayerHurtPlayer
@onready var xp_player = $XPPlayer
@onready var boss_player = $BossPlayer
@onready var music_player = $MusicPlayer
@onready var music_player2 = $MusicPlayer2

var current_music = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	music_player2.process_mode = Node.PROCESS_MODE_ALWAYS
	apply_volume_settings()
	if not SaveManager.level_up.is_connected(_on_save_manager_account_level_up_sound):
		SaveManager.level_up.connect(_on_save_manager_account_level_up_sound)
	EventBus.game_started.connect(_on_game_started)
	music_player.finished.connect(func(): if current_music == 1: music_player.play())
	music_player2.finished.connect(func(): if current_music == 2: music_player2.play())
	# Bus'ları zorla ata
	shoot_player.bus = "SFX"
	hit_player.bus = "SFX"
	death_player.bus = "SFX"
	levelup_player.bus = "SFX"
	player_hurt_player.bus = "SFX"
	xp_player.bus = "SFX"
	boss_player.bus = "SFX"
	music_player.bus = "Music"
	music_player2.bus = "Music"
	if OS.is_debug_build():
		push_warning("AudioManager: SFX bus volume (dB) at start: %s" % str(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))))

func _on_game_started():
	play_music(1)

func play_music(track: int):
	if current_music == track:
		return
	music_player.stop()
	music_player2.stop()
	current_music = track
	if track == 1:
		music_player.play()
	elif track == 2:
		music_player2.play()

func stop_music():
	music_player.stop()
	music_player2.stop()

func apply_volume_settings():
	var master = SaveManager.settings.get("master_volume", 1.0)
	var sfx = SaveManager.settings.get("sfx_volume", 1.0)
	var music = SaveManager.settings.get("music_volume", 1.0)
	AudioServer.set_bus_volume_db(0, linear_to_db(master))
	var sfx_bus = AudioServer.get_bus_index("SFX")
	if sfx_bus >= 0:
		AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(sfx))
		AudioServer.set_bus_send(sfx_bus, "Master")
	var music_bus = AudioServer.get_bus_index("Music")
	if music_bus >= 0:
		AudioServer.set_bus_volume_db(music_bus, linear_to_db(music))
		AudioServer.set_bus_send(music_bus, "Master")

func play_shoot():
	shoot_player.play()
func play_hit():
	hit_player.play()
func play_death():
	death_player.play()
func play_levelup():
	levelup_player.play()


func _on_save_manager_account_level_up_sound(_new_level: int) -> void:
	play_account_level_up()


## Hesap (meta) seviye atlayınca — `LevelUpPlayer` (`assets/sounds/levelup.mp3`).
func play_account_level_up() -> void:
	levelup_player.play()
func play_player_hurt():
	player_hurt_player.play()
func play_xp():
	xp_note_timer = 0.42
	xp_streak = mini(24, xp_streak + 1)
	var semitone = xp_notes[xp_note_index % xp_notes.size()]
	var streak_lift: float = minf(6.0, float(xp_streak) * 0.22)
	xp_player.pitch_scale = pow(2.0, (semitone + streak_lift) / 12.0)
	xp_player.play()
	xp_note_index += 1

func _process(delta):
	if xp_note_timer > 0:
		xp_note_timer -= delta
	else:
		xp_note_index = 0
		xp_streak = 0
func play_boss():
	boss_player.play()
