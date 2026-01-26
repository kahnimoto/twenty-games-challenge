class_name LandingPad
extends StaticBody2D

const TIME_DELAY_BEFORE_REWARD := 1.0

@export var lander: Lander
@export_enum("START", "FUEL", "GOAL") var type: String = "START"

var lander_in_area := false
var time_on_ground := 0.0

@onready var area: Area2D = $Area2D


func _ready() -> void:
	area.area_entered.connect(_on_lander_on_pad.bind(true))
	area.area_exited.connect(_on_lander_on_pad.bind(false))


func _process(delta: float) -> void:
	if not lander_in_area:
		return
	assert(lander is Lander)
	
	#lander.angular_damp = 30.0
	#lander.linear_damp = 30.0
	if abs(lander.angular_velocity) < 0.05 and abs(lander.linear_velocity.x) < 0.05 and abs(lander.linear_velocity.y) < 0.05:
		time_on_ground += delta
	if lander.on_ground:
		match type:
			"START":
				pass
			"FUEL":
				if time_on_ground > TIME_DELAY_BEFORE_REWARD:
					lander.fuel += 20 * delta
			"GOAL":
				if time_on_ground > TIME_DELAY_BEFORE_REWARD:
					print("YOU WIN")

func _on_lander_on_pad(other: Area2D, entering: bool):
	assert(other.is_in_group("lander_detector"))
	lander_in_area = entering
	time_on_ground = 0.0
