extends Node


const DEFAULT_MOVE_SPEED := 0.25
const PLAYER_BOOSTED_SPEED := 0.175
const MONSTER_SPEED_WHEN_PLAYER_BOOSTED := 0.4

const BOOSTED_TIME := 10.0
const PREVIEW_MONSTER_PATH := true

class Groups:
	const PICKUP = &"pickup"
	const MONSTER = &"monster"
