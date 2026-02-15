extends StaticBody2D


const LAYER := 6

var on := true

@onready var area_turn_on: Area2D = $AreaTurnOn
@onready var area_turn_off: Area2D = $AreaTurnOff


func _ready() -> void:
	area_turn_on.area_entered.connect(_on_above_entered)
	area_turn_off.area_entered.connect(_on_below_entered)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("go_down") and on:
		for o: Node2D in area_turn_off.get_overlapping_areas():
			if o.is_in_group("player_foot"):
				toggle(false)


func _on_above_entered(other: Area2D) -> void:
	if not on and other.is_in_group("player_foot"):
		toggle(true)


func _on_below_entered(other: Area2D) -> void:
	if on and other.is_in_group("player_head"):
		toggle(false)
	

func toggle(_on: bool) -> void:
	on = _on
	set_collision_layer_value(LAYER, _on)
