class_name Portal
extends Area2D

enum Dir { EAST, WEST }

@export var direction: Dir = Dir.EAST 

var target: Vector2


func _ready() -> void:
	var marker: Marker2D = get_node_or_null("Target")
	assert(marker is Marker2D)
	target = marker.global_position
	area_entered.connect(_on_area_entered)


func _on_area_entered(other: Area2D) -> void:
	var player := other.get_parent() as Player
	assert(player is Player)
	if direction == Dir.EAST and  player.movement_direction == Vector2i.LEFT:
		player.teleport_player(target)
	elif direction == Dir.WEST and  player.movement_direction == Vector2i.RIGHT:
		player.teleport_player(target)
		
