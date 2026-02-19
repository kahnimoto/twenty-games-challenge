class_name ExitTile
extends Node2D


var player_near := false

@onready var area_2d: Area2D = $Area2D

func _ready() -> void:
	area_2d.body_entered.connect(_on_player_near.bind(true))
	area_2d.body_exited.connect(_on_player_near.bind(false))


func _on_player_near(body: Node2D, enter: bool) -> void:
	assert(body.is_in_group("player"))
	player_near = enter
	print("hello")


func _unhandled_input(event: InputEvent) -> void:
	if not player_near:
		return
	if event.is_action_pressed("dig"):
		get_viewport().set_input_as_handled()
		Events.exit_reached.emit()
