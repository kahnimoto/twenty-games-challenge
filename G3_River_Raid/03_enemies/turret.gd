class_name Turret
extends Node2D


const BULLET = preload("uid://bmx40fk0i803i")

@onready var world: Node2D = get_parent()
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var bullet_spawn_marker: Marker2D = $BulletSpawnMarker


func _ready():
	animation_player.play("idle")
	get_tree().create_timer(randf_range(1, 4)).timeout.connect(_start_shooting)


func _start_shooting() -> void:
	animation_player.play("open")
	await animation_player.animation_finished
	_shoot_until_dead()


func _shoot_until_dead() -> void:
	animation_player.play("fire")
	await animation_player.animation_finished
	_shoot_until_dead()


func _on_gun_fired() -> void:
	var new_bullet: Bullet = BULLET.instantiate() as Bullet
	new_bullet.global_position = bullet_spawn_marker.global_position
	world.add_child(new_bullet)
