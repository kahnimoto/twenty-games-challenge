extends StaticBody2D

@export var lander: Lander
@export_enum("START", "FUEL", "GOAL") var type: String = "START"

var lander_in_area := false

@onready var area: Area2D = $Area2D


func _ready() -> void:
	area.area_entered.connect(_on_lander_on_pad.bind(true))
	area.area_exited.connect(_on_lander_on_pad.bind(false))


func _process(delta: float) -> void:
	if not lander_in_area:
		return
	assert(lander is Lander)
	#print(lander.velocity)
	#if lander.velocity == Vector2(0.0, 50.0):
		#match type:
			#"START":
				#pass
			#"FUEL":
				#lander.fuel += 20 * delta
			#"GOAL":
				#print("YOU WIN")

func _on_lander_on_pad(other: Area2D, entering: bool):
	assert(other.is_in_group("lander_detector"))
	lander_in_area = entering
