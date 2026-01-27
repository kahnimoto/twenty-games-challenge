class_name Level
extends Node

const BALL = preload("uid://bwthlo64pi2gx")
const BLOCK = preload("uid://d18yh1t22dtyr")
const UPGRADE = preload("uid://cslx0dsai5ly3")
const COLS = 16
const ROWS = 2
const PADDING = 0

@export var upgrades: Dictionary[UpgradeData, int]

#@onready var player_goal: Area2D = %PlayerGoal
@onready var world: Node2D = %World
@onready var ball_spawn: Marker2D = %BallSpawn
@onready var player_goal: Area2D = %PlayerGoal
@onready var tile_map: TileMapLayer = $Background/TileMapLayer
@onready var blocks_parent: Node2D = %Blocks
@onready var audio_block_destroyed: AudioStreamPlayer = $SoundEffects/AudioBlockDestroyed
@onready var balls_parent: Node2D = %Balls
@onready var player: Player = $World/Player

var balls: int
var blocks: int


func _ready() -> void:
	player_goal.body_entered.connect(_on_ball_entered_player_goal)
	Events.game_started.connect(new_ball)
	Events.block_destroyed.connect(_on_block_destroyed)
	await get_tree().process_frame
	spawn_blocks()
	blocks = %Blocks.get_child_count()
	Game.register_level(self)
	await get_tree().process_frame
	Game.new_game()


func spawn_blocks() -> void:
	for c:Node in blocks_parent.get_children():
		c.queue_free()
	var block_width: int = int((Game.MAX_X - tile_map.tile_set.tile_size.x * 2 - (PADDING * (COLS + 1))) / COLS)
	var block_height: int = 10
	var pos := Vector2.ZERO
	var start_here := Vector2(16.0 + PADDING, 200.0)
	for y in 8:
		pos.y = start_here.y + (y * (block_height + PADDING))
		for x in COLS:
			pos.x = start_here.x + (x * (block_width + PADDING))
			var block: Block = BLOCK.instantiate()
			block.size = Vector2i(block_width, 10)
			# TODO random chance to add upgrade
			blocks_parent.add_child(block)
			block.global_position = pos
			var random_upgrade: UpgradeData = upgrades.keys().pick_random()
			var roll := randi_range(0, 100)
			if roll < upgrades[random_upgrade]:
				block.upgrade = random_upgrade
				block.sprite.self_modulate = random_upgrade.color


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		get_tree().reload_current_scene()


func new_ball() -> Node2D:
	var ball = BALL.instantiate()
	balls_parent.call_deferred("add_child", ball)
	ball.global_position = ball_spawn.global_position
	balls += 1
	Events.ball_spawned.emit(balls)
	_holding_ball = ball
	return ball

var _holding_ball: Ball

func let_ball_go() -> void:
	if _holding_ball == null:
		return
	_holding_ball.velocity = -Vector2.from_angle(randf_range(0.6, PI-0.6)).normalized()
	_holding_ball.let_go = true
	_holding_ball = null

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fire"):
		let_ball_go()


func _on_block_destroyed(_score: int, upgrade: UpgradeData, _position: Vector2) -> void:
	blocks -= 1
	if blocks <= 0:
		Events.level_complete.emit()
	if upgrade and upgrade.type != UpgradeData.Types.NONE:
		audio_block_destroyed.play()
		var upgrade_node: Upgrade = UPGRADE.instantiate()
		upgrade_node.modulate = upgrade.color
		upgrade_node.data = upgrade
		world.add_child(upgrade_node)
		upgrade_node.global_position = _position + Vector2(0.0, 16.0)
		upgrade_node.global_position.x = clampf(upgrade_node.global_position.x, 32, 480 - 32)


func _on_ball_entered_player_goal(body: Node2D) -> void:
	body.queue_free()
	assert(body is Ball)
	balls -= 1
	Events.ball_lost.emit(balls)
	if balls <= 0:
		balls = 0
		Game.ball_exited()
		if not Game.over:
			new_ball()
