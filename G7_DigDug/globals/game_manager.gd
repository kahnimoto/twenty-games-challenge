# Game
extends Node

enum Ability {
	NONE,
	WALLGRAB,
	JETPACK
}

const TILE_SIZE := 16.0
const MAX_SUPPORT_LEVELS := 4
const MAX_LIVES := 3
const INVUL_FRAME_DUR := 0.8

var abilities: Dictionary[Ability, bool] = {
	Ability.NONE: false,
	Ability.WALLGRAB: false,
	Ability.JETPACK: true
}
var inventory: Dictionary[Ore.Metal, int] = {
	Ore.Metal.COPPER: 0,
	Ore.Metal.IRON: 0,
	Ore.Metal.GOLD: 0
}
var lives := MAX_LIVES


func _ready() -> void:
	Events.ore_mined.connect(_on_ore_mined)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()


func _on_ore_mined(ore: Ore.Metal) -> void:
	inventory[ore as Variant] += 1
	Events.inventory_changed.emit()


func reset() -> void:
	lives = MAX_LIVES
	for key in inventory:
		inventory[key] = 0
	for key in abilities:
		abilities[key] = false



func use(requested: Dictionary[Ore.Metal, int]) -> bool:
	var has_all := true
	for metal: Ore.Metal in requested:
		has_all = has_all and inventory[metal] >= requested[metal]
	if not has_all:
		return false
	for metal: Ore.Metal in requested:
		inventory[metal] -= requested[metal]
	Events.inventory_changed.emit()
	return true


func gain(ability: Ability) -> void:
	abilities[ability] = true
	Events.abilities_changed.emit()


func take_damage(amount: int = 1) -> void:
	var previous_lives := lives
	lives = clampi(lives - amount, 0, MAX_LIVES)
	if lives == 0:
		Events.game_over.emit()
		reset()
		get_tree().reload_current_scene.call_deferred()
	elif previous_lives != lives:
		Effects.camera_shake()
		Events.lives_changed.emit(lives)


#func recover_health(amount: int = 1) -> void:
	#var previous_lives := lives
	#lives = clampi(lives + amount, 0, MAX_LIVES)
	#if previous_lives != lives:
		#Events.lives_changed.emit(lives)
