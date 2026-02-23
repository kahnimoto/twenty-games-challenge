extends Camera2D

@export var player: Player

var offset_to_player: float

func _ready() -> void:
	assert(player is Player)
	offset_to_player = player.global_position.y


func _process(_delta: float) -> void:
	global_position.y = player.global_position.y - offset_to_player
