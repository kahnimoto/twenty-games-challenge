@tool
class_name Ore
extends Node2D


enum Metal { COPPER, IRON, GOLD, DIAMOND, WOODKIT }

const metal_colors : Dictionary[Metal, Color] = {
	Metal.COPPER: Color.ORANGE_RED,
	Metal.IRON: Color.GRAY,
	Metal.GOLD: Color.GOLD,
	Metal.DIAMOND: Color.AQUA,
	Metal.WOODKIT: Color.SADDLE_BROWN,
}

@export var type: Metal = Metal.COPPER:
	set(v):
		if v != type:
			type = v
			modulate = metal_colors[type]


var hp := 3

@onready var map: TileMapLayer = get_parent()
@onready var sprite: AnimatedSprite2D = $MetalSprite


func dig() -> bool:
	hp -= 1
	SFX.mine()
	sprite.play("decay")
	await sprite.animation_finished
	Events.dig_complete.emit(global_position)
	Events.ore_mined.emit(type)
	queue_free.call_deferred()
	return hp <= 0
