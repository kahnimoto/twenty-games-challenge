# Game
extends Node

const TILE_SIZE := 16.0



func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
