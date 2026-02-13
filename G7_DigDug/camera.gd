extends Camera2D

const SPEED := 200.0

var start_pos: Vector2

func _ready() -> void:
	start_pos = global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var direction: float = Input.get_axis("ui_up", "ui_down")
	global_position.y = max(global_position.y + SPEED * direction * delta, start_pos.y)
