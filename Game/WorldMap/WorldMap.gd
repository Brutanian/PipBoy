@tool
extends TileMap
class_name WorldMap

@export var AutoName : bool = false
@export var GridLock : bool = false

var CurrentLevel : Node2D

var LevelNodes : Dictionary
var AllAreas : Array[AreaSetting]

var CurrentArea : AreaSetting

var PlayerEnabled : bool = true
var PanPos : Vector2
var PanPosCount : int = 0

signal LevelChange()

func _ready():
	clear()
	if !Engine.is_editor_hint():
		for c in get_children():
			if c is LevelNode:
				if SaveManager.Current.IsLevelComplete(c.ID):
					c.InstantComplete()
			elif c is PathNode:
				if c.Start:
					c.Unlock(!SaveManager.Current.FirstTime)
			if c is AreaSetting:
				AllAreas.append(c)
		SaveManager.Current.FirstTime = false

func AddLevelTile(Position : Vector2i, NodeRef : LevelNode):
	LevelNodes[Position] = NodeRef

func GetLevelTile(Position : Vector2i) -> LevelNode:
	return LevelNodes.get(Position, null)

func GetTile(Layer : int, Position : Vector2i) -> int:
	if Position in get_used_cells(Layer):
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
	if GridLock:
		GridLock = false
		for c in get_children():
			c.position = (floor(c.position / 8.0) + Vector2(0.5,0.5)) * 8.0
	if !Engine.is_editor_hint():
		var PlayerArea := GetArea($PlayerMap.position)
		if CurrentArea != PlayerArea && PlayerArea != null:
			CurrentArea = PlayerArea
			CurrentArea.PlayMapMusic()
			CurrentArea.SetPalette()
			$MapUI/AreaLabel.text = CurrentArea.Name
		var LevelTile := GetLevelTile(local_to_map($PlayerMap.position))
		if LevelTile:
			$MapUI/LevelLabel.text = LevelTile.Name
		else:
			$MapUI/LevelLabel.text = ""

func AutoNameNodes():
	var LevelID : int = 0
	var PathID : int = 0
	
	var Renames : Dictionary
	var Areas : Array[AreaSetting]
	
	for c in get_children():
		if c is AreaSetting:
			Areas.append(c)
	
	for c in get_children():
		if c is LevelNode:
			c.ID = LevelID
			LevelID += 1
			var NewName : String = str("Level ",GetArea(c.position, Areas).ShortName,"-",c.ID," ",c.Name)
			Renames[c.name] = NewName
			c.name = NewName
		elif c is PathNode:
			var NewName : String = str("Path ",GetArea(c.position, Areas).ShortName,"-",PathID)
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

func GetArea(Position : Vector2, Areas : Array = []) -> AreaSetting:
	if Areas.is_empty():
		Areas = AllAreas
	for a in Areas:
		if a.get_rect().has_point(Position):
			return a
	return null

func StartedLevel(MapNode : LevelNode, LevelControl : LevelController):
	process_mode = Node.PROCESS_MODE_DISABLED
	visible = false
	$MapUI.visible = false
	CurrentLevel = LevelControl
	LevelControl.Lost.connect(FinishedLevel)
	LevelControl.Complete.connect(FinishedLevel)
	LevelChange.emit(true)
	GetArea(MapNode.position).PlayLevelMusic()

func FinishedLevel(Hidden : bool = false):
	visible = true
	$MapUI.visible = true
	process_mode = Node.PROCESS_MODE_INHERIT
	CurrentLevel = null
	LevelChange.emit(false)
	$%Camera.current = true
	CurrentArea.SetPalette()
	CurrentArea.PlayMapMusic()

func ForceFinishLevel():
	CurrentLevel.queue_free()
	FinishedLevel()

func DisablePlayer():
	$PlayerMap.process_mode = Node.PROCESS_MODE_DISABLED

func EnablePlayer():
	$PlayerMap.process_mode = Node.PROCESS_MODE_INHERIT
