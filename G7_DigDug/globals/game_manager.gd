# Game
extends Node

enum Ability {
	NONE,
	WALLGRAB,
	JETPACK
}

const TILE_SIZE := 16.0

var abilities: Dictionary[Ability, bool] = {
	Ability.NONE: false,
	Ability.WALLGRAB: false,
	Ability.JETPACK: false
}


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
