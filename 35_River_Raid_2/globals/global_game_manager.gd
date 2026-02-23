## Game
extends Node

const FUEL_DECAY := 8.0

var lives: int = 3
var fuel: float = 100.0:
	set(v):
		var new_value := clampf(v, 0.0, 100.)
		if new_value != fuel:
			fuel = new_value
var points: int = 0
var spawn: Vector2 = Vector2.ZERO
var saved_score: int = 0


func _process(delta: float) -> void:
	fuel -= FUEL_DECAY * delta
	if fuel <= 0.:
		player_crashed()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit(1)


func reset() -> void:
	lives = 3
	fuel = 100.0
	points = 0
	saved_score = 0


func checkpoint_reached(area: Area2D) -> void:
	var pos: Vector2
	for c in area.get_children():
		if c is Marker2D:
			pos = c.global_position
			break
	assert(pos and pos is Vector2)
	spawn = pos
	saved_score = points


func score(value: int) -> void:
	points += value
	Events.scored.emit(points)


func player_crashed() -> void:
	lives -= 1
	get_tree().reload_current_scene.call_deferred()
	fuel = 100.0
	await get_tree().scene_changed
	if lives <= 0:
		print("Game over!")
		saved_score = 0
		spawn = Vector2.ZERO
	else:
		if spawn != Vector2.ZERO:
			points = saved_score
			start_from_checkpoint()
			Events.scored.emit(points)


func start_from_checkpoint() -> void:
	var tilemap: Bridges = get_tree().get_first_node_in_group("bridges") as Bridges
	assert(tilemap is Bridges)
	tilemap.destroy_bridge_at(spawn + (Vector2.DOWN * 36.))
	var player: Player= get_tree().get_first_node_in_group("player") as Player
	assert(player is Player)
	player.global_position = spawn
	for node in get_tree().get_nodes_in_group("enemy"):
		var enemy: Enemy = node.get_parent() as Enemy
		if enemy.global_position.y > spawn.y:
			enemy.queue_free()
