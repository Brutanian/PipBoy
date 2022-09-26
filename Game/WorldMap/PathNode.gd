extends Node2D
class_name PathNode

const GRID_SIZE : float = 8.0

@export_group("Pathing Settings")
@export var Start : bool = false
@export var YFirst : bool = false

@export var NextNodePaths : Array[NodePath]

@export var PathSpeed : float = 0.05

var Completed : bool = false
var Unlocked : bool = false
var NextNodes : Array[Node2D]

var PathTime : float = 0
var PathIndex : int = 1

var FinishedPath : bool = false

var Paths : Array

func _ready():
	if Start:
		Unlock()
	else:
		Uncomplete()

func InstantComplete():
	DecorVis(true)
	Complete()
	while !FinishedPath:
		PathStep(true)

func Unlock(Instant : bool = false):
	if Instant:
		InstantComplete()
	else:
		Complete()
		DecorVis()
	Unlocked = true

func DecorVis(Instant : bool = false):
	for c in get_children():
		c.scale.x = 1 if randf() > 0.5 else -1
		if Instant:
			c.visible = true
		else:
			get_tree().create_timer(randf_range(0,2)).timeout.connect(c.set.bind("visible",true))

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
	get_parent().DisablePlayer()

func Uncomplete():
	Paths.clear()
	NextNodes.clear()
	Completed = false
	for c in get_children():
		c.visible = false

func _process(delta):
	position = (floor(position / GRID_SIZE) + Vector2(0.5,0.5)) * GRID_SIZE
	
	if Completed && !FinishedPath:
		if PathTime <= 0.0:
			PathTime = PathSpeed
			PathStep()
		else:
			PathTime -= delta

func PathStep(Instant : bool = false):
	var Fin : bool = true
	for I in len(NextNodes):
		var LocalPos : Vector2 = floor(NextNodes[I].position / GRID_SIZE) - floor(position / GRID_SIZE)
		if abs(LocalPos.x) + abs(LocalPos.y) >= PathIndex:
			var CellPos : Vector2i = Vector2i(GetNextNodeIndex(LocalPos,PathIndex) + floor(position / GRID_SIZE))
			get_parent().SetTile(0, CellPos, 0, 0)
			Fin = false
		elif NextNodes[I].has_method("Unlock"):
			NextNodes[I].Unlock(Instant)
	if Fin:
		get_parent().EnablePlayer()
		FinishedPath = true
	PathIndex += 1

func GetNextNodeIndex(LocalPos : Vector2, Index : int):
	var Pos : Vector2 = Vector2()
	if YFirst:
		Pos.y = clampi(Index,0,abs(LocalPos.y)) * sign(LocalPos.y)
		Index -= int(abs(Pos.y))
		Pos.x = clampi(Index,0,abs(LocalPos.x)) * sign(LocalPos.x)
	else:
		Pos.x = clampi(Index,0,abs(LocalPos.x)) * sign(LocalPos.x)
		Index -= int(abs(Pos.x))
		Pos.y = clampi(Index,0,abs(LocalPos.y)) * sign(LocalPos.y)
	return Pos
