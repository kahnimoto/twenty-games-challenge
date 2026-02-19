@tool
class_name Gem
extends Node2D


@export var type: Ore.Metal = Ore.Metal.COPPER:
	set(v):
		if v != type:
			type = v
			modulate = Ore.metal_colors[type]

var hp := 3

@onready var map: TileMapLayer = get_parent()
@onready var sprite: AnimatedSprite2D = $GemSprite


func dig() -> bool:
	hp -= 1
	sprite.play("decay")
	await sprite.animation_finished
	Events.dig_complete.emit(global_position)
	Events.ore_mined.emit(type)
	queue_free.call_deferred()
	return hp <= 0
