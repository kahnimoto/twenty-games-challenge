## Sounds
extends Node


@onready var music: AudioStreamPlayer = $Music
@onready var fire_sound: AudioStreamPlayer = $Fire
@onready var explode_sound: AudioStreamPlayer = $Explode
@onready var die_sound: AudioStreamPlayer = $Die
@onready var game_over_sound: AudioStreamPlayer = $GameOver


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("mute"):
		pause_music()


func start_music() -> void:
	music.playing = true


func pause_music() -> void:
	music.stream_paused = not music.stream_paused


func fire() -> void:
	fire_sound.play()


func explode() -> void:
	explode_sound.play()


func die() -> void:
	die_sound.play()


func game_over() -> void:
	game_over_sound.play()
