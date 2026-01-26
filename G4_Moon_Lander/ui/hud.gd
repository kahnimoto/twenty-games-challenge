extends CanvasLayer

var lander: Lander

@onready var fuel_gauge: TextureProgressBar = %FuelGauge
@onready var velocity_x: ProgressBar = %VelocityX
@onready var velocity_y: ProgressBar = %VelocityY
@onready var velocity_length: ProgressBar = %VelocityLength



func _update_fuel_gauge(new_value: float) -> void:
	var pvalue = remap(new_value, 0.0, 100.0, 15.0, 90.0)
	fuel_gauge.value = pvalue


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if lander:
		_update_fuel_gauge(lander.fuel)
		#velocity_x.value = abs(lander.linear_velocity.x)
		#velocity_y.value = abs(lander.linear_velocity.y)
		var incoming_speed: float = lander.linear_velocity.abs().length()
		var ratio: float = 0.0
		if incoming_speed < 1.0:
			ratio = remap(incoming_speed, 0.0, 1.0, 0.0, 10.0)
		elif incoming_speed < 10.0:
			ratio = remap(incoming_speed, 1.0, 10.0, 10.0, 20.0)
		else:
			ratio = remap(clampf(incoming_speed, 0.0, 100.0), 10.0, 100.0, 20.0, 100.0)
		if incoming_speed > Lander.ACCEPTABLE_LANDING_SPEED:
			velocity_length.modulate = Color.RED
		else:
			velocity_length.modulate = Color.GREEN
		velocity_length.value = ratio
