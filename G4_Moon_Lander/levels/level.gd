class_name Level
extends Node


@export var starting_fuel := 100.0
@export var maximum_fuel := 200.0

@onready var lander: Lander = %Lander


func _ready() -> void:
	lander.fuel = starting_fuel
	lander.fuel_capacity = maximum_fuel
	Hud.visible = true
