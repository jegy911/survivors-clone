extends Node

# Player sinyalleri
signal player_damaged(amount: int)
signal player_healed(amount: int)
signal player_died
signal player_leveled_up(level: int)

# Düşman sinyalleri
signal enemy_killed(position: Vector2)
signal enemy_spawned

# Oyun sinyalleri
signal game_started
signal game_over(stats: Dictionary)
signal game_paused
signal game_resumed

# XP / Gold sinyalleri
signal xp_gained(amount: int)
signal gold_collected(amount: int)
