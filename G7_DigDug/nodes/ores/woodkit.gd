class_name WoodKit
extends Node2D


@onready var area: Area2D = $Area2D

func _ready() -> void:
	area.body_entered.connect(_on_player_near)


func _on_player_near(body: Node2D) -> void:
	assert(body.is_in_group("player"))
	Events.ore_mined.emit(Ore.Metal.WOODKIT)
	SFX.build()
	queue_free.call_deferred()
