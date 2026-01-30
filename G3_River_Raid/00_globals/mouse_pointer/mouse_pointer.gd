extends Node

@onready var moving: AnimatedSprite2D = %Moving
@onready var aiming: AnimatedSprite2D = %Aiming

func _ready() -> void:
	moving.show()
	aiming.hide()
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	Events.player_is_aiming.connect(aiming.show)
	Events.player_is_aiming.connect(moving.hide)
	Events.player_is_moving.connect(aiming.hide)
	Events.player_is_moving.connect(moving.show)

func _process(_delta: float) -> void:
	var mouse_position: Vector2 = get_viewport().get_mouse_position()
	moving.global_position = mouse_position
	aiming.global_position = mouse_position
