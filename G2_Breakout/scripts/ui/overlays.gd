extends CanvasLayer

@onready var play_button: Button = %PlayButton
@onready var value_message: Label = %ValueMessage

var _restart_game := false

func _ready() -> void:
	play_button.pressed.connect(_on_play_button_pressed)
	visibility_changed.connect(_on_visibility_change)
	get_tree().paused = true
	Events.game_won.connect(_on_game_won)
	Events.game_lost.connect(_on_game_lost)


func _on_play_button_pressed() -> void:
	if _restart_game:
		get_tree().reload_current_scene()
	hide()


func _on_visibility_change() -> void:
	if visible:
		get_tree().paused = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		get_tree().paused = false
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _on_game_won() -> void:
	_restart_game = true
	value_message.text = "YOU WON!"
	play_button.text = "Go again!"
	show()


func _on_game_lost() -> void:
	_restart_game = true
	value_message.text = "YOU LOST!"
	play_button.text = "Try again!"
	show()
