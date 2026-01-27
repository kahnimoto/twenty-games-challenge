class_name Block
extends StaticBody2D


@export var size: Vector2i = Vector2i(65, 10)
@export var upgrade: UpgradeData
@export_range(1, 10, 1) var hits_to_destroy: int = 1

var _hits: int = 0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	(sprite.texture as GradientTexture2D).width = size.x
	(sprite.texture as GradientTexture2D).height = size.y
	(collision_shape.shape as RectangleShape2D).size.x = size.x
	(collision_shape.shape as RectangleShape2D).size.y = size.y
	collision_shape.position = size / 2

func hit() -> void:
	_hits += 1
	if _hits >= hits_to_destroy:
		if upgrade:
			Events.block_destroyed.emit(10, upgrade, global_position)
		else:
			Events.block_destroyed.emit(10, UpgradeData.new(), global_position)
		queue_free()
