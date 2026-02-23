class_name FuelDepot
extends Area2D


const POINTS: int = 80
const FUEL_PER_SECOND := 32.0

var player_fueling := false


func _ready() -> void:
	area_entered.connect(_on_player_contact.bind(true))
	area_exited.connect(_on_player_contact.bind(false))


func _process(delta: float) -> void:
	if player_fueling:
		Game.fuel += FUEL_PER_SECOND * delta


func _on_player_contact(other: Area2D, enter: bool) -> void:
	if other.is_in_group("player"):
		player_fueling = enter


func destroy() -> void:
	Game.score(80)
	queue_free()
