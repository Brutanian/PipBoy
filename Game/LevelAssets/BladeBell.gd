extends CharacterBody2D

const FlyForce : float = -30

var AirTime : float = 3
var RestTime : float = 1

var Counter : float = 0

var Spawn : Vector2

var Dead : bool = false
var Disabled : bool = true

@onready var Playback : AnimationNodeStateMachinePlayback = $StateMachine.get("parameters/playback")

func _process(delta):
	if Dead || Disabled:
		velocity += Vector2(0,100)
	else:
		var State = Playback.get_current_node()
		
		if State == "Fly":
			Counter += delta
			if Counter > AirTime:
				Counter = 0
				Travel("Float")
			else:
				velocity.y = pow(1 - Counter / AirTime, 2.0) * FlyForce
		elif State == "Float":
			velocity.y = move_toward(velocity.y, 64, delta * 10)
			if is_on_floor():
				Travel("Land")
		elif State == "Land":
			Counter += delta
			if Counter > RestTime:
				Counter = 0
				Travel("Fly")
		
	move_and_slide()

func Flatten(_By):
	if Playback.get_current_node() != "Fly":
		Die()
		return true
	return false

func Flip(_By):
	Die()

func Die():
	Dead = true
	collision_layer = 0
	Playback.start("Die")

func Travel(StateName : String):
	if Playback.get_current_node() != StateName:
		Playback.travel(StateName)

func SetPlayer(Plyr):
	Spawn = position
	Plyr.Respawned.connect(PlayerRespawn)
	Plyr.GotCheckpoint.connect(PlayerGetCheckpoint)
	print(name, " Player Connected")

func PlayerRespawn(AtCheckpoint = null):
	if AtCheckpoint != null:
		if self in AtCheckpoint.Respawnables:
			Respawn()
		else:
			Travel("Die")
	else:
		Respawn()

func PlayerGetCheckpoint(Checkpoint):
	if !Dead:
		Checkpoint.Respawnables.append(self)

func Respawn():
	Dead = false
	Disabled = true
	collision_layer = 4
	position = Spawn
	velocity = Vector2()
	Counter = 0
	Playback.start("Land")

func BodyDetect(Body):
	if Body.is_in_group("Player"):
		Disabled = false
