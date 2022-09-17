@tool
extends TileMap

func _ready():
	clear()

func GetTile(Layer : int, Position : Vector2i) -> int:
	var Data = get_cell_tile_data(Layer, Position)
	if Data:
		return get_cell_tile_data(Layer, Position).terrain
	return -1

func SetTile(Layer : int, Position : Vector2i, TerrainIndex : int, TileIndex : int):
	set_cells_terrain_connect(Layer, [Position], TerrainIndex, TileIndex)
