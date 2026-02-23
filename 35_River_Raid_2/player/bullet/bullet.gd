class_name Bullet
extends Area2D


const SPEED := 256.0
const LIFETIME := 0.8

var alive_for := 0.0


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	body_shape_entered.connect(_on_body_shape_entered)


func _physics_process(delta: float) -> void:
	alive_for += delta
	global_position.y -= SPEED * delta
	if alive_for >= LIFETIME:
		queue_free.call_deferred()


func _on_area_entered(other: Area2D) -> void:
	if other.is_in_group("enemy"):
		var enemy := other.get_parent() as Enemy
		enemy.kill()
	elif other.is_in_group("fuel"):
		other.destroy()
	queue_free.call_deferred()


func _on_body_shape_entered(_body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	assert(body.is_in_group("bridges") and body is Bridges)
	var bridges := body as Bridges
	Game.score(500)
	bridges.destroy_bridge_at(global_position)
	queue_free.call_deferred()
