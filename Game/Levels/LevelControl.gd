extends TileMap
class_name LevelController

signal Complete(Hidden : bool)
signal Lost()

var Player : CharacterBody2D

func _ready():
	for c in get_used_cells(0):
		var TileInfo : TileData = get_cell_tile_data(0, c)

func SetPlayer(PlayerNode : CharacterBody2D):
	Player = PlayerNode
	for c in get_children():
		if c.has_method("SetPlayer"):
			c.SetPlayer(PlayerNode)

func LevelComplete(Hidden : bool = false):
	process_mode = Node.PROCESS_MODE_DISABLED
	Filter.DitherOut(LevelCompleteTrig.bind(Hidden))

func LevelCompleteTrig(Hidden : bool = false):
	Filter.DitherIn()
	Complete.emit(Hidden)
	queue_free()
