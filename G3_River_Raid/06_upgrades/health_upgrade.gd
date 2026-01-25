class_name HealthUpgrade
extends Node2D


func _physics_process(delta: float) -> void:
	global_position.y += delta * 150.0
	if global_position.y >= 1000.0:
		queue_free()
