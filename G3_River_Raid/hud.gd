extends CanvasLayer

@onready var fuel_gauge: TextureProgressBar = %FuelGauge
@onready var player: Lander = %Player


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(player is Lander)


func _update_fuel_gauge(new_value: float) -> void:
	var pvalue = remap(new_value, 0.0, 100.0, 15.0, 90.0)
	fuel_gauge.value = pvalue


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	_update_fuel_gauge(player.fuel)
