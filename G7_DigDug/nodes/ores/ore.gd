class_name Ore
extends Node2D


enum Metal { COPPER, IRON, GOLD }

const metal_colors : Dictionary[Metal, Color] = {
	Metal.COPPER: Color.ORANGE_RED,
	Metal.IRON: Color.GRAY,
	Metal.GOLD: Color.GOLD
}

@export var type: Metal = Metal.COPPER:
	set(v):
		if v != type:
			type = v
			modulate = metal_colors[type]

var hp := 3

@onready var sprite: AnimatedSprite2D = $Sprite2D
@onready var map: TileMapLayer = get_parent()


func _ready() -> void:
	modulate = metal_colors[type]


func dig() -> bool:
	hp -= 1
	sprite.play("decay")
	await sprite.animation_finished
	Events.dig_complete.emit(global_position)
	queue_free.call_deferred()
	return hp <= 0
