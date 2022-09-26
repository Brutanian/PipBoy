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

var Invincibility : float = 0
var Frozen : bool = false

var Checkpoint

signal Die()
signal Respawned()
signal GotCheckpoint()

func _ready():
	call_deferred("DeferredReady")

func DeferredReady():
	get_parent().call_deferred("SetPlayer",self)
	position.y += 1
	RespawnPoint = position
	collision_layer = 2

func SetInvinvibility(Length : float):
	Invincibility = Length

func _physics_process(delta):
	var Invincible = Invincibility > 0
	if Invincible:
		Invincibility -= delta
	
	if !Frozen:
		if position.y > 8:
			Kill()
		
		var State : String = Playback.get_current_node()
		
		$CanvasLayer/Label.text = State
		$CanvasLayer/Label.text += "\n" + str(collision_mask)
		
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
			velocity.y += delta
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
					if Input.is_action_pressed("Down"):
						Travel("Root")
					else:
						Travel("Idle")
				velocity.x = move_toward(velocity.x, 0, DECEL * delta)
		else:
			if direction:
				velocity.x = move_toward(velocity.x, direction * MaxSpeed, ACCEL * 0.8 * delta)
				$Sprite.flip_h = velocity.x < 0
			else:
				velocity.x = move_toward(velocity.x, 0, DECEL * 0.8 * delta)
		
		if CoyoteTime && JumpBuffer:
			if !(State == "Root" || State == "Unroot"):
				velocity.y = JUMP_VELOCITY - remap(abs(velocity.x), 0, 120, 0, 20)
				CoyoteTime = 0
				JumpBuffer = 0
				Travel("Jump")
			elif State == "Root":
				velocity.y = JUMP_VELOCITY - 40
				CoyoteTime = 0
				JumpBuffer = 0
				Travel("Unroot Jump")
		
		if $UnrootRay.is_colliding():
			var Collider = $UnrootRay.get_collider()
			if Collider.has_method("Flip"):
				Collider.Flip(self)
		
		for i in get_slide_collision_count():
			var Collision = get_slide_collision(i)
			var Collider = Collision.get_collider()
			
			if Collision.get_position().y > position.y + 3.5:
				if Collider.has_method("Stomp"):
					Collider.Stomp(self)
					velocity.y = min(JUMP_VELOCITY, velocity.y - JUMP_VELOCITY)
			
			elif Collider.is_in_group("Enemy") && !Invincible:
				Kill()
		
	move_and_slide()

func Freeze():
	Frozen = true
	velocity = Vector2()

func Kill():
	Freeze()
	Filter.DitherOut(KillTrig)

func KillTrig():
	if Checkpoint != null:
		Respawned.emit(Checkpoint)
		Checkpoint.Use(self)
		position.y += 1
	else:
		position = RespawnPoint
		Respawned.emit(null)
	Frozen = false
	Die.emit()
	Filter.DitherIn()
	process_mode = Node.PROCESS_MODE_INHERIT

func Travel(StateName : String):
	if Playback.get_current_node() != StateName:
		Playback.travel(StateName)
