extends Node


func _ready() -> void:
	pass


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	if event.is_action_pressed("ui_text_backspace"):
		get_tree().reload_current_scene()
