# Event
extends Node

@warning_ignore_start("unused_signal")

signal game_started
signal game_over
signal level_loaded
signal map_changed
signal dig_started(position: Vector2)
signal dig_complete(position: Vector2)
