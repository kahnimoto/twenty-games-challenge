## Global Game Manager
extends Node

const LEVEL_ONE_STOP = preload("uid://dhrv8xoswlnl0")
const LEVEL_CAVE = preload("uid://ielyj2jlvskg")

var levels: Array[PackedScene] = [
	LEVEL_ONE_STOP,
	LEVEL_CAVE
]



func _ready() -> void:
	Events.game_started.connect(_on_level_started)
	Events.level_completed.connect(_on_level_completed)
	get_tree().scene_changed.connect(_on_level_loaded)


func _on_level_started() -> void:
	levels = [
		LEVEL_ONE_STOP,
		LEVEL_CAVE
	]
	_on_level_completed()


func _on_level_completed() -> void:
	var active_level: PackedScene = levels.pop_front()
	if not active_level:
		get_tree().quit()
	else:
		get_tree().change_scene_to_packed(active_level)
		

func _on_level_loaded() -> void:
	Events.level_loaded.emit()
