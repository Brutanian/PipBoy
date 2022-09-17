extends CharacterBody2D

const JUMP_BUFFER_FRAMES : int = 10

const MAX_SPEED = 100.0
const ACCEL = 400.0
const DECEL = 800.0
const JUMP_VELOCITY = -200.0

@onready var Playback : AnimationNodeStateMachinePlayback = $StateMachine.get("parameters/playback")

var Gravity = Vector2(0,980)

var CoyoteTime : int = 0
var JumpBuffer : int = 0

func _physics_process(delta):
	$CanvasLayer/Label.text = str(velocity)
	
	var State : String = Playback.get_current_node()
	
	if CoyoteTime:
		CoyoteTime -= 1
	if JumpBuffer:
		JumpBuffer -= 1
	
	if is_on_floor():
		CoyoteTime = JUMP_BUFFER_FRAMES
	else:
		if velocity.y > 0:
			Travel("Fall")
		velocity += Gravity * delta
	
	if Input.is_action_just_pressed("A"):
		JumpBuffer = JUMP_BUFFER_FRAMES
	
	if CoyoteTime && JumpBuffer:
		velocity.y = JUMP_VELOCITY
		Travel("Jump")
	
	var direction = Input.get_axis("Left", "Right")
	
	if is_on_floor():
		if direction:
			Travel("Run")
			if State == "Run":
				velocity.x = move_toward(velocity.x, direction * MAX_SPEED, ACCEL * delta)
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
			velocity.x = move_toward(velocity.x, direction * MAX_SPEED, ACCEL * 0.5 * delta)
			$Sprite.flip_h = velocity.x < 0
		else:
			velocity.x = move_toward(velocity.x, 0, DECEL * 0.5 * delta)
	
	move_and_slide()

func Travel(StateName : String):
	if Playback.get_current_node() != StateName:
		Playback.travel(StateName)
