class_name Level
extends Node


const BALL = preload("uid://bwthlo64pi2gx")
const BLOCK = preload("uid://d18yh1t22dtyr")
const UPGRADE = preload("uid://cslx0dsai5ly3")

@export_category("Upgrades")
@export var upgrades: Dictionary[UpgradeData, int]
@export_category("Blocks")
@export_range(4, 32, 1.0) var block_cols: int = 8
@export_range(1, 12, 1.0) var block_rows: int = 4
@export_range(0, 8, 1.0) var block_padding: int = 0

@onready var world: Node2D = %World
@onready var ball_spawn: Marker2D = %BallSpawn
@onready var player_goal: Area2D = %PlayerGoal
@onready var tile_map: TileMapLayer = $Background/TileMapLayer
@onready var blocks_parent: Node2D = %Blocks
@onready var audio_block_destroyed: AudioStreamPlayer = $SoundEffects/AudioBlockDestroyed
@onready var balls_parent: Node2D = %Balls
@onready var player: Player = $World/Player
@onready var upgrades_parent: Node2D = %Upgrades

var blocks: int
var _holding_ball: Ball


func _ready() -> void:
	player_goal.body_entered.connect(_on_ball_entered_player_goal)
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
	var block_width: int = int((Game.MAX_X - tile_map.tile_set.tile_size.x * 2 - (block_padding * (block_cols + 1))) / block_cols)
	var block_height: int = 10
	var pos := Vector2.ZERO
	var start_here := Vector2(16.0 + block_padding, 200.0)
	for y in block_rows:
		pos.y = start_here.y + (y * (block_height + block_padding))
		for x in block_cols:
			pos.x = start_here.x + (x * (block_width + block_padding))
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


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("fire"):
		let_ball_go()


func new_ball() -> Node2D:
	var ball = BALL.instantiate()
	balls_parent.call_deferred("add_child", ball)
	ball.global_position = ball_spawn.global_position
	_holding_ball = ball
	return ball


func let_ball_go() -> void:
	if _holding_ball == null:
		return
	_holding_ball.velocity = -Vector2.from_angle(randf_range(0.6, PI-0.6)).normalized()
	_holding_ball.let_go = true
	_holding_ball = null


func _on_block_destroyed(_score: int, upgrade: UpgradeData, _position: Vector2) -> void:
	blocks -= 1
	if blocks <= 0:
		Events.level_complete.emit()
		Events.game_won.emit()
		return
	if upgrade and upgrade.type != UpgradeData.Types.NONE:
		audio_block_destroyed.play()
		var upgrade_node: Upgrade = UPGRADE.instantiate()
		upgrade_node.modulate = upgrade.color
		upgrade_node.data = upgrade
		upgrades_parent.add_child(upgrade_node)
		upgrade_node.global_position = _position + Vector2(0.0, 16.0)
		upgrade_node.global_position.x = clampf(upgrade_node.global_position.x, 32, 480 - 32)


func _on_ball_entered_player_goal(body: Node2D) -> void:
	body.queue_free()
	assert(body is Ball)
	Game.ball_exited()


func _on_turn_over() -> void:
	for c:Node2D in upgrades_parent.get_children():
		c.queue_free()
