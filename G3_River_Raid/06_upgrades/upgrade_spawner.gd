class_name UpgradeSpawner
extends Node2D

const HEALTH_UPGRADE = preload("uid://bxap161m33kby")


func _ready():
	$Timer.timeout.connect(_on_time)

func _on_time():
	var u = HEALTH_UPGRADE.instantiate()
	%World.add_child(u)
	u.global_position = $Marker2D.global_position
