@tool
class_name Enemy
extends Node2D

enum Type { TANKER, HELI, JET }

const POINTS: Dictionary[Type, int] = {
	Type.TANKER: 30,
	Type.HELI: 60,
	Type.JET: 100
}
const TEXTURES: Dictionary[Type, AtlasTexture] = {
	Type.TANKER: preload("uid://bbqvi46ewilru"),
	Type.HELI: preload("uid://ca2dnv7dt6n80"),
	Type.JET: preload("uid://c13gbwo8rgi23")
	
}
const SHAPES: Dictionary[Type, Shape2D] = {
	Type.TANKER: preload("uid://bvv8inapy25x7"),
	Type.HELI: preload("uid://cjuonk6xvhiwf"),
	Type.JET: preload("uid://bb8y430f5426v")
	
}
const SPEEDS: Dictionary[Type, float] = {
	Type.TANKER: 8.,
	Type.HELI: 16.,
	Type.JET: 32.
}

@export var type: Type:
	set(v):
		if type != v:
			type = v
			if is_node_ready():
				_set_texture()
			
@export_range(1., 5., 1.) var speed_level := 1.

var active := false
var start: Vector2
var target: Vector2
var pathing_to_target := true

@onready var sprite: Sprite2D = $Sprite2D
@onready var crash_area: Area2D = $Crash
@onready var collision_shape: CollisionShape2D = $Crash/CollisionShape2D
@onready var active_area: Area2D = $Active


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_set_texture()
	_set_shape()
	_set_activity()
	_set_pathing()


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if Game.over:
		queue_free()
	if active:
		_update_position(delta)


func _update_position(delta: float) -> void:
	var movement := SPEEDS[type] * speed_level * delta
	if pathing_to_target:
		global_position.x += movement
		if global_position.x >= target.x:
			global_position.x = target.x
			pathing_to_target = false
			sprite.flip_h = true
	else:
		global_position.x -= movement
		if global_position.x <= start.x:
			global_position.x = start.x
			pathing_to_target = true
			sprite.flip_h = false


func _set_activity() -> void:
	active_area.area_entered.connect(_on_starting_up)
	active_area.area_exited.connect(func(_a): queue_free.call_deferred()) 


func _on_starting_up(other: Area2D) -> void:
	assert(other.is_in_group("player"))
	active = true


func _set_pathing() -> void:
	start = global_position
	for c in get_children():
		if c is Marker2D:
			target = c.global_position
			break
	assert(target is Vector2)


func _set_texture() -> void:
	assert(type in TEXTURES)
	sprite.texture = TEXTURES[type]


func _set_shape() -> void:
	assert(type in SHAPES)
	collision_shape.shape = SHAPES[type]


func kill() -> void:
	var points: int = POINTS[type]
	Game.score(points)
	Sounds.explode()
	queue_free()


func crash() -> void:
	Game.player_crashed()
