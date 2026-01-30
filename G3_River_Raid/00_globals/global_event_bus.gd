extends Node


@warning_ignore_start("unused_signal")

signal lives_changed(new_value: int)
signal player_is_aiming
signal player_is_moving
signal player_started
signal level_loaded

#region test signals
signal movement_type_changed(new_value: Game.MovementTypes)
signal speed_changed(new_value: float)
#endregion
