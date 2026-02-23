## Sounds
extends Node


@onready var music: AudioStreamPlayer = $Music
@onready var sound: AudioStreamPlayer = $Sound


func start_music() -> void:
	music.playing = true


func pause_music() -> void:
	music.playing = true


func play_sound() -> void:
	sound.play()
