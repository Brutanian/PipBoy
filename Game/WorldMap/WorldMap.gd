@tool
extends TileMap
class_name WorldMap

@export var AutoName : bool = false

var CurrentLevel : Node2D

func _ready():
	clear()

func GetTile(Layer : int, Position : Vector2i) -> int:
	var Data = get_cell_tile_data(Layer, Position)
	if Data:
		return get_cell_tile_data(Layer, Position).terrain
	return -1

func SetTile(Layer : int, Position : Vector2i, TerrainIndex : int, TileIndex : int):
	set_cells_terrain_connect(Layer, [Position], TerrainIndex, TileIndex)

func _process(delta):
	if AutoName:
		AutoName = false
		AutoNameNodes()

func AutoNameNodes():
	var LevelID : int = 0
	var PathID : int = 0
	
	var Renames : Dictionary
	
	for c in get_children():
		if c is LevelNode:
			c.ID = LevelID
			LevelID += 1
			var NewName : String = str("Level ",c.WorldID,"-",c.ID," ",c.Name)
			Renames[c.name] = NewName
			c.name = NewName
		elif c is PathNode:
			var NewName : String = str("Path ",c.WorldID,"-",PathID)
			Renames[c.name] = NewName
			c.name = NewName
			PathID += 1
	
	for c in get_children():
		if c is PathNode:
			for i in len(c.NextNodePaths):
				for OldName in Renames.keys():
					c.NextNodePaths[i] = NodePath(str(c.NextNodePaths[i]).replace(OldName, Renames[OldName]))
	
	for c in get_children():
		if c is PathNode:
			var Str : String = "Connected To:"
			if len(c.NextNodePaths) > 0:
				for i in c.NextNodePaths:
					Str += str("\n", c.get_node(i).name)
			c.editor_description = Str
	
	for c in get_children():
		if c is PathNode:
			for i in c.NextNodePaths:
				var NN = c.get_node(i)
				NN.editor_description += str("\n", c.name)

func LevelStarted():
	visible = false
	process_mode = Node.PROCESS_MODE_DISABLED

func LevelFinished():
	visible = false
	process_mode = Node.PROCESS_MODE_INHERIT

func PlayLevel(LevelScene : PackedScene):
	var NewLevel = LevelScene.instantiate()
	get_tree().root.add_child(NewLevel)
	CurrentLevel = NewLevel
	visible = false

func FinishLevel():
	pass
