extends Sprite2D

const GRID_SIZE : float = 8.0
const MOVE_SPEED : float = 32.0

var AtRestingSpot : bool = true
var GoingTo : Vector2
var Heading : Vector2i

func _ready():
	GoingTo = position

func CanMove(Direction : Vector2i):
	var Map : TileMap = get_parent() as TileMap
	var MapPos : Vector2i = Map.local_to_map(position)
	return Map.GetTile(0, MapPos + Direction) == 0 

func GetAllowedDirections() -> Array[Vector2i]:
	var Dirs : Array[Vector2i]
	for d in [Vector2i.UP,Vector2i.DOWN,Vector2i.LEFT,Vector2i.RIGHT]:
		if CanMove(d): Dirs.append(d)
	return Dirs

func Move(Direction : Vector2i):
	Heading = Direction
	AtRestingSpot = false
	GoingTo += Direction * GRID_SIZE

func _physics_process(delta):
	if AtRestingSpot:
		if Input.is_action_just_pressed("Up") && CanMove(Vector2i.UP):
			Move(Vector2i.UP)
		elif Input.is_action_just_pressed("Down") && CanMove(Vector2i.DOWN):
			Move(Vector2i.DOWN)
		elif Input.is_action_just_pressed("Left") && CanMove(Vector2i.LEFT):
			Move(Vector2i.LEFT)
		elif Input.is_action_just_pressed("Right") && CanMove(Vector2i.RIGHT):
			Move(Vector2i.RIGHT)
	elif GoingTo == position:
		var Dirs := GetAllowedDirections()
		if len(Dirs) != 2:
			AtRestingSpot = true
		else:
			Dirs.erase(-Heading)
			Move(Dirs[0])
			position = position.move_toward(GoingTo, MOVE_SPEED * delta)
	else:
		position = position.move_toward(GoingTo, MOVE_SPEED * delta)
