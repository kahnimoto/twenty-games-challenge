extends Camera2D

var _player: Player

func _ready() -> void:
	_player = get_parent() as Player
	assert(_player and _player is Player)
	assert(_player.tilemap and _player.tilemap is TileMapLayer)
	update_limits()


func update_limits() -> void:
	var bounds: Array[Vector2] = []
	bounds.append(Vector2(_player.tilemap.get_used_rect().position * _player.tilemap.tile_set.tile_size))
	bounds.append(Vector2(_player.tilemap.get_used_rect().end * _player.tilemap.tile_set.tile_size))
	#limit_top = int(bounds[0].y)
	#limit_bottom = int(bounds[1].y)
	#limit_left = int(bounds[0].x)
	limit_right = int(bounds[1].x)
	pass
