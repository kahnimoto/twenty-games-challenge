extends Node

@onready var music: AudioStreamPlayer = $Music
@onready var power_up: AudioStreamPlayer = $PowerUp
@onready var dead: AudioStreamPlayer = $Dead
@onready var win: AudioStreamPlayer = $Win
@onready var pings: Array[AudioStreamPlayer] = [
	$Ping1,
	$Ping2,
	$Ping3,
	$Ping4
]

func _ready() -> void:
	Events.level_completed.connect(win.play)
	Events.level_failed.connect(dead.play)
	Events.monster_eaten.connect(_on_monster_eaten)
	Events.crumb_eaten.connect(_on_crumb_eaten)
	Events.player_state_changed.connect(_on_player_state_changed)


func _on_monster_eaten(_m) -> void:
	power_up.play()


func _on_crumb_eaten(_c) -> void:
	pings.pick_random().play()


func _on_player_state_changed(new_state: Player.State) -> void:
	match new_state:
		Player.State.BOOSTED:
			power_up.play()
