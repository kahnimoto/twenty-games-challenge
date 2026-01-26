extends CanvasLayer

@export var green_color: Color
@export var red_color: Color

var lander: Lander

@onready var fuel_gauge: TextureProgressBar = %FuelGauge
@onready var velocity_x: ProgressBar = %VelocityX
@onready var velocity_y: ProgressBar = %VelocityY
@onready var velocity_length: TextureProgressBar = %VelocityLength
@onready var velocity_value: Label = %VelocityValue
@onready var fuel_value: Label = %FuelValue



func _update_fuel_gauge() -> void:
	fuel_gauge.value = remap(lander.fuel, 0.0, lander.fuel_capacity, 10.0, 93.0)
	fuel_value.text = "%d%%" % int(remap(lander.fuel, 0.0, lander.fuel_capacity, 0.0, 100.0) )


func _update_velocity_gauge() -> void:
	var incoming_speed: float = lander.previous_linear_velocity.abs().length()
	velocity_value.text = str(int(incoming_speed))
	if incoming_speed < Lander.ACCEPTABLE_LANDING_SPEED:
		velocity_value.modulate = green_color
	else:
		velocity_value.modulate = Color.WHITE
	
	velocity_length.value =  remap(incoming_speed, 0.0, 120, 10.0, 93.0)


func _process(_delta: float) -> void:
	if lander and not lander.dead:
		_update_fuel_gauge()
		_update_velocity_gauge()
