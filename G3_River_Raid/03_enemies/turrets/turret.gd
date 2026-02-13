class_name Turret
extends Node2D


const BULLET = preload("uid://bmx40fk0i803i")

var target: Node2D
var is_open := false

@onready var world: Node2D = get_parent()
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var bullet_spawn_marker: Marker2D = $BulletSpawnMarker
@onready var visibility_cone: Area2D = %VisibilityCone
@onready var turret_body: Area2D = $TurretBody


func _ready():
	animation_player.play("idle")
	#get_tree().create_timer(randf_range(1, 4)).timeout.connect(_start_shooting)
	visibility_cone.area_entered.connect(_on_player_seen)
	visibility_cone.area_exited.connect(_on_player_left)
	turret_body.area_entered.connect(_on_impact)

func _on_player_seen(area: Area2D) -> void:
	assert(area.is_in_group("player"))
	target = area.get_parent()
	shoot()


func _on_player_left(area: Area2D) -> void:
	assert(area.is_in_group("player"))
	target = null


func _on_impact(area: Area2D) -> void:
	if area.is_in_group("player"):
		# explode and give player damage
		queue_free()
	elif area.is_in_group("player_bullets"):
		queue_free()


func open() -> bool:
	animation_player.play("open")
	await animation_player.animation_finished
	return true


func close() -> bool:
	animation_player.play("open", 0, -1.0, true)
	await animation_player.animation_finished
	return true


func shoot() -> void:
	if not target:
		await close()
		return
	if not is_open:
		await open()
	animation_player.play("fire")
	await animation_player.animation_finished
	shoot()

func _on_gun_fired() -> void:
	var new_bullet: Bullet = BULLET.instantiate() as Bullet
	new_bullet.global_position = bullet_spawn_marker.global_position
	world.add_child(new_bullet)
