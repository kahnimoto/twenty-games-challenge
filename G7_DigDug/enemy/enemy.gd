class_name Enemy
extends Node2D


const COLORS: Array[Color] = [
	Color.CHOCOLATE,
	Color.DARK_GOLDENROD,
	Color.DARK_SLATE_GRAY,
	Color.INDIAN_RED
]
const COLLISION_BIT_MASK: int = 16

var active_state: State
var sees_player: bool = false
var facing_right: bool = true
var states: Array[State] = []

@onready var orientation: Node2D = $Orientation
@onready var body: Sprite2D = $Orientation/Body


func _ready() -> void:
	for c in $StateMachine.get_children():
		if c is State:
			states.append(c as State)
	active_state = states[0]
	assert(active_state is EnemyIdle)
	active_state.enter()
	body.self_modulate = COLORS.pick_random()


func _physics_process(delta: float) -> void:
	if Game.game_over:
		return
	assert(active_state is State)
	var new_state = active_state.tick(delta)
	if new_state:
		active_state.exit()
		active_state = new_state
		new_state.enter()
	orientation.scale.x = 1. if facing_right else -1.


func find_floor() -> Vector2:
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var target_vector: Vector2 = global_position + Vector2.DOWN * 1000.0
	var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(global_position, target_vector, COLLISION_BIT_MASK)
	var result: Dictionary = space_state.intersect_ray(query)
	var hit_pos: Vector2 = result.position + Vector2.UP * Game.TILE_SIZE * 0.5
	assert(result.collider is TileMapLayer, "We should not have hit something other than the tilemap!")
	var tilemap: TileMapLayer = result.collider as TileMapLayer
	var target: Vector2 = tilemap.map_to_local(tilemap.local_to_map(hit_pos))
	return target
