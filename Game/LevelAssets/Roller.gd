extends CharacterBody2D

@export var Floats : bool = false
@export var Spikey : bool = false

@export var MaxSpeed : float = 16
@export var Acceleration : float = 32

@export var RespawnOnDeath : bool = true
@export var Gravity : float = 100

@export_enum("Left:-1","Right:1") var Direction : int = -1

var CurDirection : int

@export var DeleteOnColNumber : int = 0

var Cols : int = 0

var SpriteRot : float = 0

var Spawn : Vector2

var Player : CharacterBody2D

func _ready():
	add_collision_exception_with($Standable)
	Spawn = position
	CurDirection = Direction

func SetPlayer(P):
	Player = P
	P.Respawned.connect(Respawn)

func _physics_process(delta):
	$GroundParticles.emitting = is_on_floor()
	
	if is_on_floor():
		velocity.x = move_toward(velocity.x, CurDirection * MaxSpeed, Acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, CurDirection * MaxSpeed * 0.5, Acceleration * delta)
	velocity.y += Gravity * delta
	
	SpriteRot = wrapf(SpriteRot + delta * velocity.x * 0.1, -TAU, TAU)
	$Sprite.rotation = snapped(SpriteRot, PI * 0.03125)
	
	var PrevVel = velocity
	
	$Standable.constant_linear_velocity = velocity
	$Standable.constant_angular_velocity = rad_to_deg(delta * velocity.x * 0.1)
	
	move_and_slide()
	
	if is_on_floor():
		if PrevVel.y > 25:
			velocity.y = PrevVel.y * -0.5
			velocity.x *= 0.95
	
	if is_on_wall():
		CurDirection *= -1
		velocity.x = CurDirection * MaxSpeed * 0.8
		velocity.y -= 30
		Cols += 1
		if Cols == DeleteOnColNumber:
			if RespawnOnDeath:
				Respawn(null)
			else:
				Enable(false)
	
	if position.y > 128:
		if RespawnOnDeath:
			Respawn(null)
		else:
			Enable(false)

func Respawn(_CP):
	Enable(true)
	position = Spawn
	velocity = Vector2()
	CurDirection = Direction
	Cols = 0

func Enable(Set : bool):
	if Set:
		process_mode = Node.PROCESS_MODE_INHERIT
		visible = true
	else:
		process_mode = Node.PROCESS_MODE_DISABLED
		visible = false

func BodyEntered(Body):
	if Body.has_method("Flatten"):
		Body.Flatten(self)
