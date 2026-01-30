class_name Level
extends Node

@export var speed := 20.0

var world_offset := 0.0
var paused := true

@onready var auto_camera: Camera2D = get_node_or_null("%Camera")

func _ready() -> void:
	if auto_camera:
		auto_camera.enabled = true
	Events.player_started.connect(self.set.bind("paused", false))


func _process(delta: float) -> void:
	if auto_camera and not paused:
		world_offset -= speed * delta
		auto_camera.position.y = world_offset
