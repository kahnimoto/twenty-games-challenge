class_name Player
extends Area2D


const BULLET = preload("uid://c3riy7b6uv272")
const STRAFE := 64.
const SPEED := 32.
const SPEEDS: Dictionary[float, float] = {
	-1.0: 0.25, 0.0: 1.0, 1.0: 2.0
}
const SHOOT_COOL_DOWN := 0.5

@export var bullet_parent: Node2D

var cool_down := 0.0

@onready var bullet_spawn_marker: Marker2D = $BulletSpawn


func _ready() -> void:
	body_shape_entered.connect(_on_collision)
	area_entered.connect(_on_area_entered)


func _process(delta: float) -> void:
	if Game.over:
		return
	cool_down += delta
	if cool_down >= SHOOT_COOL_DOWN and Input.is_action_pressed("shoot"):
		shoot()


func _physics_process(delta: float) -> void:
	if Game.over:
		return
	var direction: float = Input.get_axis("move_left", "move_right")
	if direction != 0.:
		global_position.x += STRAFE * delta * direction
	global_position.y -= _get_modified_speed() * delta
	

func _get_modified_speed() -> float:
	var speed_input: float = Input.get_axis("move_down", "move_up")
	return SPEED * SPEEDS[speed_input]


func _on_area_entered(other: Area2D) -> void:
	if other.is_in_group("enemy"):
		Game.player_crashed()
	elif other.is_in_group("checkpoint"):
		Game.checkpoint_reached(other)
	else:
		push_warning("What is this node?")


func _on_collision(_body_rid: RID, _body: Node2D, _body_shape_index: int, _local_shape_index: int)  -> void:
	Game.player_crashed()


func shoot() -> void:
	Sounds.fire()
	cool_down = 0.0
	var new_bullet := BULLET.instantiate() as Bullet
	bullet_parent.add_child(new_bullet)
	new_bullet.global_position = bullet_spawn_marker.global_position
