class_name Level
extends Node

@export var speed := 20.0

var world_offset := 0.0

@onready var auto_camera: Camera2D = %Camera

func _ready() -> void:
	auto_camera.enabled = true


func _process(delta: float) -> void:
	world_offset -= speed * delta
	auto_camera.position.y = world_offset


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	if event.is_action_pressed("ui_accept"):
		get_tree().reload_current_scene()
