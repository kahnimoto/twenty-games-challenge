class_name FuelDepot
extends Area2D


const POINTS: int = 80
const FUEL_PER_SECOND := 32.0

var player_fueling := false

@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D


func _ready() -> void:
	area_entered.connect(_on_player_contact.bind(true))
	area_exited.connect(_on_player_contact.bind(false))


func _process(delta: float) -> void:
	if player_fueling:
		Game.fuel += FUEL_PER_SECOND * delta
	if Game.fuel >= Game.MAX_FUEL:
		audio.playing = false

func _on_player_contact(other: Area2D, enter: bool) -> void:
	if other.is_in_group("player"):
		player_fueling = enter
		audio.playing = enter
		


func destroy() -> void:
	Game.score(80)
	Sounds.explode()
	queue_free()
