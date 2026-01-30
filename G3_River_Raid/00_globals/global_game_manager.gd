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


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	if event.is_action_pressed("ui_accept"):
		started = false
		get_tree().reload_current_scene()
		Events.level_loaded.emit()
	if event is InputEventMouseButton and not started:
		started = true
		Events.player_started.emit()
	if event is InputEventKey:
		if event.is_action_pressed("hotkey_1"):
			movement_type = MovementTypes.DIRECT
		elif event.is_action_pressed("hotkey_2"):
			movement_type = MovementTypes.DELAYED
		elif event.is_action_pressed("hotkey_3"):
			movement_type = MovementTypes.CONSTANT
		elif event.is_action_pressed("hotkey_4"):
			movement_type = MovementTypes.INDEPENDANT
	if event is InputEventMouse:
		if (event as InputEventMouse).is_action("speed_up"):
			movement_speed = clampf(movement_speed + 25., 50., 1000.)
		elif (event as InputEventMouse).is_action("speed_down"):
			movement_speed = clampf(movement_speed - 25., 50., 1000.)
