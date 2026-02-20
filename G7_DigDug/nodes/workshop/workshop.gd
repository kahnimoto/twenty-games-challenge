class_name Workshop
extends Node2D


var player_is_near: bool = false

@onready var area: Area2D = $Area2D
@onready var key_hint: Control = %KeyHint


func _ready() -> void:
	area.body_entered.connect(_on_player_near)
	area.body_exited.connect(_on_player_left)
	key_hint.hide()


func _unhandled_input(event: InputEvent) -> void:
	if player_is_near and (event.is_action_pressed("use") or event.is_action_pressed("dig")):
		Events.craft_started.emit()
		get_viewport().set_input_as_handled()
		if Game.pickaxe_level == 1 and Game.use({Ore.Metal.DIAMOND: 1}):
			Game.upgrade_pickaxe()
			await SFX.craft()
		elif not Game.abilities[Game.Ability.SCAFFOLD] and Game.use({Ore.Metal.WOODKIT: 1}):
			Game.gain(Game.Ability.SCAFFOLD)
			Game.gain(Game.Ability.BRIDGE)
			await SFX.craft()
		elif not Game.abilities[Game.Ability.WALLGRAB] and Game.use({Ore.Metal.COPPER: 2, Ore.Metal.IRON: 1}):
			Game.gain(Game.Ability.WALLGRAB)
			await SFX.craft()
		elif not Game.abilities[Game.Ability.JETPACK] and Game.use({Ore.Metal.IRON: 2, Ore.Metal.GOLD: 1}):
			Game.gain(Game.Ability.JETPACK)
			await SFX.craft()
		Events.craft_completed.emit()


func _on_player_near(body: Node2D) -> void:
	assert(body.is_in_group("player"))
	key_hint.show()
	player_is_near = true
	Events.preview_costs_show.emit()


func _on_player_left(body: Node2D) -> void:
	assert(body.is_in_group("player"))
	key_hint.hide()
	player_is_near = false
	Events.preview_costs_hide.emit()
