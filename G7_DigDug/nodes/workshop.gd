class_name Workshop
extends Node2D


var player_is_near: bool = false

@onready var area: Area2D = $Area2D


func _ready() -> void:
	area.body_entered.connect(_on_player_near)
	area.body_exited.connect(_on_player_left)


func _unhandled_input(event: InputEvent) -> void:
	if player_is_near and (event.is_action_pressed("use") or event.is_action_pressed("dig")):
		get_viewport().set_input_as_handled()
		if Game.use({Ore.Metal.COPPER: 2, Ore.Metal.IRON: 1}):
			Game.gain(Game.Ability.WALLGRAB)
		if Game.use({Ore.Metal.IRON: 2, Ore.Metal.GOLD: 1}):
			Game.gain(Game.Ability.JETPACK)
		if Game.use({Ore.Metal.DIAMOND: 1}):
			Game.upgrade_pickaxe()


func _on_player_near(body: Node2D) -> void:
	assert(body.is_in_group("player"))
	player_is_near = true
	Events.preview_costs_show.emit()


func _on_player_left(body: Node2D) -> void:
	assert(body.is_in_group("player"))
	player_is_near = true
	Events.preview_costs_hide.emit()
