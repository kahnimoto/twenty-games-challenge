extends Node


@warning_ignore_start("unused_signal")

signal level_started(total: int)
signal level_completed
signal level_failed
signal crumb_eaten(left: int)
signal monster_eaten(monster: Monster)
signal player_state_changed(new_state: Player.State)
