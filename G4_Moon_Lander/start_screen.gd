extends Node


@onready var start_button: Button = %StartButton


func _ready() -> void:
	start_button.pressed.connect(_on_start_game_button_pressed)
	Hud.visible = false
	start_button.grab_focus()


func _on_start_game_button_pressed() -> void:
	Events.game_started.emit()
