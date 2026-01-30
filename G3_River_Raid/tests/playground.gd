extends Node


@onready var player: Player = %Player


func _ready() -> void:
	pass # Replace with function body.


func _process(_delta: float) -> void:
	pass
	

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	if event.is_action_pressed("ui_accept"):
		player.recover_health()
