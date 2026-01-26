class_name Level
extends Node

@export var starting_fuel := 100.0
@export var maximum_fuel := 200.0

@onready var lander: Lander = %Lander

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	lander.fuel = starting_fuel
	lander.fuel_capacity = maximum_fuel
	Hud.visible = true
	#Events.message.emit("Get to the other side!")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
