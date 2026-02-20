class_name HintUIConnected
extends Control

@export var connected: Control

func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)


func _on_visibility_changed() -> void:
	if visible and connected is Control:
		connected.show()
