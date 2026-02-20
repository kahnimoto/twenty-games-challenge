# Game
extends Node

enum Ability {
	NONE,
	WALLGRAB,
	JETPACK,
	SCAFFOLD,
	BRIDGE,
}

const TILE_SIZE := 16.0
const MAX_LIVES := 3
const INVUL_FRAME_DUR := 0.8
const WALL_LAYER_NUMBER := 5
const WALL_BITMASK := 16
const LAVA_LAYER_NUMBER := 7
const LAVA_BITMASK := 64
const LEVELS: Array[PackedScene] = [
	preload("res://levels/tutorial.tscn"),
	preload("res://levels/level_scaffold.tscn"),
	preload("res://levels/level_climb.tscn"),
	preload("res://levels/playground.tscn"),
]

var current_level := 0
var abilities: Dictionary[Ability, bool] = {
	Ability.NONE: false,
	Ability.WALLGRAB: false,
	Ability.JETPACK: false,
	Ability.SCAFFOLD: false,
	Ability.BRIDGE: false,
}
var pickaxe_level := 1
var inventory: Dictionary[Ore.Metal, int] = {
	Ore.Metal.COPPER: 0,
	Ore.Metal.IRON: 0,
	Ore.Metal.GOLD: 0,
	Ore.Metal.DIAMOND: 0,
	Ore.Metal.WOODKIT: 0,
}
var lives := MAX_LIVES
var game_over := false
var scaffold_support_levels := 3


func _ready() -> void:
	Events.ore_mined.connect(_on_ore_mined)
	Events.exit_reached.connect(_on_player_reached_exit)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()


func _on_ore_mined(ore: Ore.Metal) -> void:
	inventory[ore] += 1
	Events.inventory_changed.emit()


func _on_player_reached_exit() -> void:
	get_tree().paused = true
	current_level += 1
	if current_level >= LEVELS.size():
		current_level = 0
	get_tree().change_scene_to_packed(LEVELS[current_level])
	await get_tree().scene_changed
	reset()
	get_tree().paused = false


func reset() -> void:
	game_over = false
	lives = MAX_LIVES
	#pickaxe_level = 1
	for key in inventory:
		inventory[key] = 0
	Events.inventory_changed.emit()
	#for key in abilities:
		#abilities[key] = false


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


func upgrade_pickaxe(new_level: int = 2) -> void:
	pickaxe_level = new_level
	Events.abilities_changed.emit()


func take_damage(amount: int = 1) -> void:
	var previous_lives := lives
	lives = clampi(lives - amount, 0, MAX_LIVES)
	if previous_lives != lives:
		Effects.camera_shake()
		Events.lives_changed.emit(lives)

	if lives == 0:
		game_over = true
		Events.game_over.emit()
		await get_tree().create_timer(1.).timeout
		Effects.end_shake()
		reset()
		get_tree().reload_current_scene.call_deferred()


#func recover_health(amount: int = 1) -> void:
	#var previous_lives := lives
	#lives = clampi(lives + amount, 0, MAX_LIVES)
	#if previous_lives != lives:
		#Events.lives_changed.emit(lives)
