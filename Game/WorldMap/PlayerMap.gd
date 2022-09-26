extends Sprite2D

const GRID_SIZE : float = 8.0
const MOVE_SPEED : float = 100.0

var AtRestingSpot : bool = true
var GoingTo : Vector2
var Heading : Vector2i

func _ready():
	if !SaveManager.Current.FirstTime:
		position = SaveManager.Current.PlayerPosition
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
	if Direction != Heading:
		match Direction:
			Vector2i.UP:
				$Animator.play("Up")
			Vector2i.DOWN:
				$Animator.play("Down")
			Vector2i.LEFT:
				$Animator.play("Left")
			Vector2i.RIGHT:
				$Animator.play("Right")
	Heading = Direction
	AtRestingSpot = false
	GoingTo += Direction * GRID_SIZE

func _process(delta):
	if AtRestingSpot:
		if Input.is_action_pressed("Up") && CanMove(Vector2i.UP):
			Move(Vector2i.UP)
		elif Input.is_action_pressed("Down") && CanMove(Vector2i.DOWN):
			Move(Vector2i.DOWN)
		elif Input.is_action_pressed("Left") && CanMove(Vector2i.LEFT):
			Move(Vector2i.LEFT)
		elif Input.is_action_pressed("Right") && CanMove(Vector2i.RIGHT):
			Move(Vector2i.RIGHT)
		elif Input.is_action_just_pressed("A"):
			var Map : TileMap = get_parent() as TileMap
			var MapPos : Vector2i = Map.local_to_map(position)
			var LevelRef = Map.GetLevelTile(MapPos)
			if LevelRef != null:
				LevelRef.PlayLevel()
		
	elif GoingTo == position:
		var Dirs := GetAllowedDirections()
		
		var Map : TileMap = get_parent() as TileMap
		var MapPos : Vector2i = Map.local_to_map(position)
		
		if len(Dirs) != 2 || Map.GetLevelTile(MapPos) != null:
			AtRestingSpot = true
			$Animator.play("Idle")
			SaveManager.Current.PlayerPosition = position
		else:
			Dirs.erase(-Heading)
			Move(Dirs[0])
			position = position.move_toward(GoingTo, MOVE_SPEED * delta)
	else:
		position = position.move_toward(GoingTo, MOVE_SPEED * delta)
