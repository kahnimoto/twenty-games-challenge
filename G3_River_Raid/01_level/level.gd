class_name Level
extends Node

@export var speed := 20.0

var world_offset := 0.0

@onready var auto_camera: Camera2D = get_node_or_null("%Camera")

func _ready() -> void:
	if auto_camera:
		auto_camera.enabled = true


func _process(delta: float) -> void:
	if auto_camera and Game.started and not Game.game_over:
		world_offset -= speed * delta
		auto_camera.position.y = world_offset
