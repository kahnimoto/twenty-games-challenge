extends Node

enum MovementTypes {
	DIRECT,
	DELAYED,
	CONSTANT,
	INDEPENDANT,
}

var movement_type: MovementTypes = MovementTypes.DELAYED:
	set(v):
		movement_type = v
		Events.movement_type_changed.emit(v)
var movement_speed: float = 300.0:
	set(v):
		movement_speed = v
		Events.speed_changed.emit(v)
var started := false
var game_over := false


func _ready() -> void:
	Events.lives_changed.connect(_on_player_life_changed)


func _on_player_life_changed(new_value: int) -> void:
	if not game_over and new_value <= 0:
		game_over = true
		Events.game_over.emit()

func restart() -> void:
	started = false
	game_over = false
	get_tree().reload_current_scene()
	Events.level_loaded.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not started and event is InputEventMouseButton:
		started = true
		Events.player_started.emit()
	elif event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	elif event.is_action_pressed("ui_accept"):
		restart()
	elif event is InputEventKey:
		if event.is_action_pressed("hotkey_1"):
			movement_type = MovementTypes.DIRECT
		elif event.is_action_pressed("hotkey_2"):
			movement_type = MovementTypes.DELAYED
		elif event.is_action_pressed("hotkey_3"):
			movement_type = MovementTypes.CONSTANT
		elif event.is_action_pressed("hotkey_4"):
			movement_type = MovementTypes.INDEPENDANT
	elif event is InputEventMouse:
		if (event as InputEventMouse).is_action("speed_up"):
			movement_speed = clampf(movement_speed + 25., 50., 1000.)
		elif (event as InputEventMouse).is_action("speed_down"):
			movement_speed = clampf(movement_speed - 25., 50., 1000.)
