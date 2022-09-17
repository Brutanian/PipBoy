@tool
extends Node2D
class_name PathNode

const GRID_SIZE : float = 8.0

@export_group("Editor Testing")
@export var CompleteTest : bool = false

@export_group("Pathing Settings")
@export_enum("Default", "Completed", "Unlocked") var InitialState : int = 0

@export var NextNodePaths : Array[NodePath]
@export var NodesToActivate : Array[NodePath]

@export var PathSpeed : float = 1.0

var Completed : bool = false
var NextNodes : Array[Node2D]

var PathTime : float = 0
var PathIndex : int = 1

var FinishedPath : bool = false

var Paths : Array

func _ready():
	if InitialState == 1:
		call_deferred("Complete")
	elif InitialState == 2:
		call_deferred("Unlocked")
	else:
		Uncomplete()

func Unlocked():
	Complete()

func Complete():
	Paths.clear()
	NextNodes.clear()
	PathIndex = 1
	FinishedPath = false
	get_parent().SetTile(0, floor(position / GRID_SIZE), 0, 0)
	for i in NextNodePaths:
		NextNodes.append(get_node(i))
		Paths.append([])
	Completed = true

func Uncomplete():
	Paths.clear()
	NextNodes.clear()
	Completed = false

func _process(delta):
	if Engine.is_editor_hint():
		position = (floor(position / GRID_SIZE) + Vector2(0.5,0.5)) * GRID_SIZE
		if CompleteTest:
			CompleteTest = false
			get_parent().clear()
			Complete()
	
	if Completed && !FinishedPath:
		if PathTime <= 0.0:
			PathTime = PathSpeed
			var Fin : bool = true
			for I in len(NextNodes):
				var LocalPos : Vector2 = floor(NextNodes[I].position / GRID_SIZE) - floor(position / GRID_SIZE)
				if abs(LocalPos.x) + abs(LocalPos.y) >= PathIndex:
					var CellPos : Vector2i = Vector2i(GetNextNodeIndex(LocalPos,PathIndex) + floor(position / GRID_SIZE))
					get_parent().SetTile(0, CellPos, 0, 0)
					Fin = false
				elif NextNodes[I].has_method("Unlocked"):
					NextNodes[I].Unlocked()
			if Fin:
				FinishedPath = true
			PathIndex += 1
		else:
			PathTime -= delta

func GetNextNodeIndex(LocalPos : Vector2, Index : int):
	var Pos : Vector2 = Vector2()
	Pos.x = clampi(Index,0,abs(LocalPos.x)) * sign(LocalPos.x)
	Index -= int(abs(Pos.x))
	Pos.y = clampi(Index,0,abs(LocalPos.y)) * sign(LocalPos.y)
	return Pos
