extends Area2D

func _ready() -> void:
	area_entered.connect(_on_player_enter_winning_area)


func _on_player_enter_winning_area(other: Area2D) -> void:
	assert(other.is_in_group("player"))
	Game.over = true
