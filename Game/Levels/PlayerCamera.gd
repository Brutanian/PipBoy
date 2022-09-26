@tool
extends Camera2D

const SCREEN_SIZE : Vector2i = Vector2i(160,144)

@export var CamLimit : Vector2i = Vector2i(20, 18)

var Player : CharacterBody2D

func SetPlayer(New : CharacterBody2D):
	Player = New
	position = ClampedPos(Player.position)
	Player.Die.connect(TP)

func _process(delta):
	if Engine.is_editor_hint():
		CamLimit = Vector2i(max(CamLimit.x, 20),max(CamLimit.y, 18))
		queue_redraw()

func _physics_process(delta):
	if !Engine.is_editor_hint():
		if Player:
			position = lerp(position, ClampedPos(Player.position), 0.1)

func TP():
	position = ClampedPos(Player.position)

func ClampedPos(Position : Vector2):
	var Limit = CamLimit * 8
	Position.x = clamp(Position.x, SCREEN_SIZE.x * 0.5, Limit.x - SCREEN_SIZE.x * 0.5)
	Position.y = clamp(Position.y, -Limit.y + SCREEN_SIZE.y * 0.5, SCREEN_SIZE.y * -0.5)
	return Position

func _draw():
	if Engine.is_editor_hint():
		var Rect : Rect2i = Rect2i(Vector2i(0,-CamLimit.y * 8), CamLimit * 8)
		draw_rect(Rect, Color.GREEN, false, 3.0)
