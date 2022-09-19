extends TileMap
class_name LevelController

signal Complete()
signal Lost()

var Player : CharacterBody2D

func _ready():
	for c in get_used_cells(0):
		var TileInfo : TileData = get_cell_tile_data(0, c)
		var SpawnInst = TileInfo.get_custom_data("Spawn Instance")
		if SpawnInst is PackedScene:
			var NewInst : Node2D = SpawnInst.instantiate()
			NewInst.position = map_to_local(c)
			add_child(NewInst)
			set_cell(0, c)

func SetPlayer(PlayerNode : CharacterBody2D):
	Player = PlayerNode
	$Camera.SetPlayer(PlayerNode)

func LevelComplete():
	Complete.emit()
	queue_free()
