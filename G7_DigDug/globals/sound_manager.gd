# SFX
extends Node

@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var mining_sound: AudioStreamPlayer = $MiningSound
@onready var too_hard: AudioStreamPlayer = $TooHardSound
@onready var dig_sound: AudioStreamPlayer = $DigSound
@onready var building_sound: AudioStreamPlayer = $BuildingSound
@onready var extra_scaffold_sound: AudioStreamPlayer = $ExtraScaffoldSound


func dig() -> void:
	dig_sound.play()


func mine() -> void:
	mining_sound.play()

func build() -> bool:
	building_sound.play()
	await building_sound.finished
	return true

func build_extra() -> bool:
	extra_scaffold_sound.play()
	await extra_scaffold_sound.finished
	return true


func hardness() -> void:
	too_hard.play()


func start_music() -> void:
	music_player.playing = true


func pause_music() -> void:
	music_player.playing = false
