# Effects global
extends Node


const SHAKE_MAX := 20.0
const SHAKE_DECAY := 5.0
const SHAKE_FALLOFF = preload("uid://corlwxk7ge3ri")

var _camera_shake: float = 0.0
var camera: Camera2D


func _ready() -> void:
	#Events.game_over.connect(end_shake)
	Events.level_loaded.connect(end_shake)


func _process(delta: float) -> void:
	if _camera_shake > 0.0:
		if camera and camera is Camera2D:
			var ratio: float = SHAKE_FALLOFF.sample(remap(_camera_shake, 0.0, SHAKE_MAX, 0.0, 1.0))
			camera.offset = Vector2(randf_range(0., _camera_shake), randf_range(0., _camera_shake)) * ratio
			_camera_shake = clampf(_camera_shake - SHAKE_DECAY * delta, 0.0, SHAKE_MAX)
		else:
			_camera_shake = 0.0


func camera_shake(strength: float = 1.0) -> void:
	if not camera:
		camera = get_tree().get_first_node_in_group("camera")
	assert(camera is Camera2D, "Level must have a Camera2D with the 'camera' group")
	_camera_shake = clampf(_camera_shake + 10. * strength, 0.0, SHAKE_MAX)


func end_shake() -> void:
	_camera_shake = 0.0
