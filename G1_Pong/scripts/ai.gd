extends Node2D


const SPEED := 400.0

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var dir := Input.get_axis("up", "down")
	if dir != 0.0:
		var desired_position: float = global_position.y + (dir * delta * SPEED) * -1
		global_position.y = clampf(desired_position, Game.MIN_Y, Game.MAX_Y)
