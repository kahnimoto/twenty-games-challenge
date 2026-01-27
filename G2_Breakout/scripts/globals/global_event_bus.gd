extends Node


@warning_ignore_start("unused_signal")

signal game_started
signal game_lost
signal game_won

signal life_lost(new_value: int)
signal life_gained(new_value: int)
signal score_updated(new_value: int)

signal level_changed
signal level_complete

signal ball_lost(current_ball_count: int)
signal ball_spawned(current_ball_count: int)

signal upgrade_spawned
signal upgrade_accepted
signal upgrade_timer_changed(type: UpgradeData.Types, time_left: float)

signal block_destroyed(score: int, upgrade: Upgrade, position: Vector2)

signal message(msg: String)
