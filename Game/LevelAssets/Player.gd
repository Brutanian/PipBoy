extends CharacterBody2D

const JUMP_BUFFER_FRAMES : int = 10

const MAX_SPEED = 80.0
const MAX_SPRINT_SPEED = 120.0
const ACCEL = 400.0
const DECEL = 800.0
const JUMP_VELOCITY = -90.0

const MAX_HOLD_TIME : float = 1

@onready var Playback : AnimationNodeStateMachinePlayback = $StateMachine.get("parameters/playback")

var Gravity = Vector2(0,700)

var CoyoteTime : int = 0
var JumpBuffer : int = 0
var AirTime : float = 0

var RespawnPoint : Vector2

signal Die()

func _ready():
	get_parent().SetPlayer(self)
	RespawnPoint = position

func _physics_process(delta):
	
	if position.y > 0:
		Kill()
	
	var State : String = Playback.get_current_node()
	
	$CanvasLayer/Label.text = State
	$CanvasLayer/Label.text += str(velocity)
	
	if CoyoteTime:
		CoyoteTime -= 1
	if JumpBuffer:
		JumpBuffer -= 1
	
	var MaxSpeed : float
	if Input.is_action_pressed("B"):
		MaxSpeed = MAX_SPRINT_SPEED
	else:
		MaxSpeed = MAX_SPEED
	
	if is_on_floor():
		CoyoteTime = JUMP_BUFFER_FRAMES
		AirTime = 0
	else:
		AirTime += delta
		if velocity.y > 0:
			Travel("Fall")
		if Input.is_action_pressed("A"):
			velocity += Gravity * delta * remap(min(AirTime, MAX_HOLD_TIME), 0, MAX_HOLD_TIME, 0, 0.9)
		else:
			velocity += Gravity * delta
	
	
	if Input.is_action_just_pressed("A"):
		JumpBuffer = JUMP_BUFFER_FRAMES
	
	if CoyoteTime && JumpBuffer:
		velocity.y = JUMP_VELOCITY - remap(abs(velocity.x), 0, 120, 0, 20)
		Travel("Jump")
	
	var direction = Input.get_axis("Left", "Right")
	
	if is_on_floor():
		if direction:
			if abs(velocity.x) >= 90:
				Travel("Sprint")
			else:
				Travel("Run")
			if State == "Run" || State == "Sprint":
				velocity.x = move_toward(velocity.x, direction * MaxSpeed, ACCEL * delta)
				$Sprite.flip_h = direction < 0
			else:
				velocity.x = move_toward(velocity.x, 0, DECEL * 0.5 * delta)
		else:
			if abs(velocity.x) > 50:
				Travel("Slide")
			else:
				Travel("Idle")
			velocity.x = move_toward(velocity.x, 0, DECEL * delta)
	else:
		if direction:
			velocity.x = move_toward(velocity.x, direction * MaxSpeed, ACCEL * 0.8 * delta)
			$Sprite.flip_h = velocity.x < 0
		else:
			velocity.x = move_toward(velocity.x, 0, DECEL * 0.8 * delta)
	
	move_and_slide()

func Kill():
	Die.emit()
	position = RespawnPoint

func Travel(StateName : String):
	if Playback.get_current_node() != StateName:
		Playback.travel(StateName)
