class_name Upgrade
extends Area2D

@export var data: UpgradeData

var speed: float = 50.0

func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	global_position.y += speed * delta
	if global_position.y >= Game.MAX_X + 32.0:
		queue_free()
