extends CharacterBody2D

const SPEED : int = 160

var Player : CharacterBody2D
var InRange : bool = false
var InSight : bool = false

var Direction : float = 0
var TargetPosition : Vector2

var Dead : bool = false
var Disabled : bool = true

var Spawn : Vector2

@onready var Playback : AnimationNodeStateMachinePlayback = $StateMachine.get("parameters/playback")

func _ready():
	DeferredReady.call_deferred()

func DeferredReady():
	TargetPosition = position
	Spawn = position

func _physics_process(delta):
	if Dead || Disabled:
		velocity -= Vector2(velocity.x,-100 * delta)
	else:
		var State : String = Playback.get_current_node()
		
		if InRange:
			$RayCast.target_position = to_local(Player.position)
			InSight = ($RayCast.is_colliding() && $RayCast.get_collider().is_in_group("Player"))
		
		if is_on_floor():
			if InRange && InSight:
				TargetPosition = Player.position + Player.velocity * delta
			Direction = sign(round(to_local(TargetPosition).x))
			
			
			if Direction == 1: 
				$Sprite.flip_h = true
				Travel("Moving")
			elif Direction == -1:
				$Sprite.flip_h = false
				Travel("Moving")
			else:
				Travel("Idle")
				
			if (TargetPosition.y < position.y - 16 || position.distance_squared_to(TargetPosition) > 1600) && State == "Moving" || State == "Idle":
				var XDist : float = clamp(TargetPosition.x - position.x, -64, 64)
				var YDist : float = abs(clamp(TargetPosition.y - position.y,-32, -0.1))
				var Total : float = XDist + YDist
				velocity = Vector2(XDist,-YDist - abs(XDist)) * randf_range(0.9,1.5)
				Travel("Jump")
			else:
				velocity.x = Direction * SPEED * delta
		else:
			velocity -= Vector2(velocity.x * 0.1,-100) * delta
			var Dot = velocity.normalized().dot(Vector2.UP)
			if Dot > 0.5:
				Travel("InAirUp")
			elif Dot < -0.5:
				Travel("InAirDown")
			else:
				Travel("InAirHor")
	move_and_slide()

func PlayerEntered(body):
	if body.is_in_group("Player"):
		Player = body
		InRange = true
		Disabled = false

func PlayerExited(body):
	if body.is_in_group("Player"):
		InRange = false
		TargetPosition = position

func Travel(StateName : String):
	if Playback.get_current_node() != StateName:
		Playback.travel(StateName)

func MoveTimer():
	if !(InRange && InSight):
		TargetPosition = position + Vector2(randf_range(-48,48),randf_range(0,32))

func Flatten(_By):
	Die()
	return true

func Flip(_By):
	Die()

func Die():
	collision_layer = 0
	Dead = true
	Travel("Die")

func SetPlayer(Plyr):
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
	collision_layer = 4
	position = Spawn
	TargetPosition = position
	if Dead:
		Dead = false
		Disabled = true
		Playback.start("Idle")
