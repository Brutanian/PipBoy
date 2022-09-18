extends TileMap
class_name LevelController

signal LevelComplete()
signal LevelLost()

func _ready():
	for c in get_used_cells(1):
		var TileInfo : TileData = get_cell_tile_data(1, c)
		var SpawnInst = TileInfo.get_custom_data("Spawn Instance")
		if SpawnInst is PackedScene:
			var NewInst : Node2D = SpawnInst.instantiate()
			NewInst.position = map_to_local(c)
			add_child(NewInst)
		set_cell(1, c)
