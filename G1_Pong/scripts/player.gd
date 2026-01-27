extends Node2D


const SPEED := 300.0


func _process(delta: float) -> void:
	var dir := Input.get_axis("up", "down")
	if dir != 0.0:
		var desired_position: float = global_position.y + (dir * delta * SPEED)
		global_position.y = clampf(desired_position, Game.MIN_Y, Game.MAX_Y)
