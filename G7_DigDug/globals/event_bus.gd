# Event
extends Node

@warning_ignore_start("unused_signal")

signal game_started
signal game_over
signal level_loaded
signal map_changed
signal dig_started(position: Vector2)
signal dig_complete(position: Vector2)
signal scaffold_requested(position: Vector2)
signal scaffold_placed(position: Vector2)
signal player_position_changed(position: Vector2)
signal ore_mined(ore: Ore.Metal)
signal inventory_changed
signal abilities_changed
signal preview_costs_show
signal preview_costs_hide
signal tried_to_digg_too_hard
signal lives_changed(new_value: int)
