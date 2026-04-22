extends Node

const MUSIC_TRACK_COUNT := 6
var MUSIC_PATHS: PackedStringArray = PackedStringArray([
	"res://assets/sounds/music1.mp3",
	"res://assets/sounds/music2.mp3",
	"res://assets/sounds/music3.mp3",
	"res://assets/sounds/music4.mp3",
	"res://assets/sounds/music5.mp3",
	"res://assets/sounds/music6.mp3",
])

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

var _music_streams: Array[AudioStream] = []
var current_music: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	_load_music_streams()
	apply_volume_settings()
	if not SaveManager.level_up.is_connected(_on_save_manager_account_level_up_sound):
		SaveManager.level_up.connect(_on_save_manager_account_level_up_sound)
	EventBus.game_started.connect(_on_game_started)
	if not music_player.finished.is_connected(_on_music_player_finished):
		music_player.finished.connect(_on_music_player_finished)
	# Bus'ları zorla ata
	shoot_player.bus = "SFX"
	hit_player.bus = "SFX"
	death_player.bus = "SFX"
	levelup_player.bus = "SFX"
	player_hurt_player.bus = "SFX"
	xp_player.bus = "SFX"
	boss_player.bus = "SFX"
	music_player.bus = "Music"
	if OS.is_debug_build():
		push_warning("AudioManager: SFX bus volume (dB) at start: %s" % str(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))))


func _load_music_streams() -> void:
	_music_streams.clear()
	for p in MUSIC_PATHS:
		var st: AudioStream = load(p) as AudioStream
		if st == null:
			push_error("AudioManager: stream yüklenemedi: %s" % p)
			continue
		_music_streams.append(st)
	if _music_streams.size() != MUSIC_PATHS.size():
		push_error("AudioManager: beklenen %d müzik, yüklenen %d" % [MUSIC_PATHS.size(), _music_streams.size()])


func get_music_track_count() -> int:
	return _music_streams.size()


## Koşu başında menüden gelen parçayı koru; yalnız hiç çalmıyorsa `music1`.
func _on_game_started() -> void:
	if current_music > 0:
		if music_player.stream_paused:
			music_player.stream_paused = false
		elif not music_player.has_stream_playback():
			play_music(current_music)
		return
	play_music(1)


func get_music_track_basename(track: int) -> String:
	if track < 1 or track > MUSIC_TRACK_COUNT:
		return "-"
	return "music%d" % track


func play_music(track: int) -> void:
	if track < 1 or track > _music_streams.size():
		return
	var idx: int = track - 1
	if current_music == track and music_player.stream_paused:
		music_player.stream_paused = false
		return
	if current_music == track and music_player.has_stream_playback() and not music_player.stream_paused:
		return
	music_player.stop()
	music_player.stream_paused = false
	current_music = track
	music_player.stream = _music_streams[idx]
	music_player.play()


func _on_music_player_finished() -> void:
	if current_music <= 0 or current_music > _music_streams.size():
		return
	var next_track: int = (current_music % _music_streams.size()) + 1
	play_music(next_track)


func music_prev() -> void:
	if current_music <= 0:
		play_music(1)
		return
	var t: int = current_music - 1
	if t < 1:
		t = _music_streams.size()
	play_music(t)


func music_next() -> void:
	if current_music <= 0:
		play_music(1)
		return
	var t: int = (current_music % _music_streams.size()) + 1
	play_music(t)


func pause_music() -> void:
	if current_music > 0 and music_player.has_stream_playback() and not music_player.stream_paused:
		music_player.stream_paused = true


func resume_music() -> void:
	if current_music <= 0:
		return
	if music_player.stream_paused:
		music_player.stream_paused = false
	elif not music_player.has_stream_playback():
		play_music(current_music)


func is_music_playing() -> bool:
	return current_music > 0 and music_player.has_stream_playback() and not music_player.stream_paused


func is_music_paused() -> bool:
	return current_music > 0 and music_player.stream_paused


func stop_music():
	music_player.stop()
	music_player.stream_paused = false
	current_music = 0


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
