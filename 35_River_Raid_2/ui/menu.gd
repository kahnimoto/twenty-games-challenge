extends Node

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		Game.reset()
		get_tree().change_scene_to_file("res://playground.tscn")
