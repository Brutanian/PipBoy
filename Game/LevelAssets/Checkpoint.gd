extends Node2D

var Activated : bool = false

var Lives : int = 3
var PreviousCheckpoint

var Respawnables : Array

func SetPlayer(P):
	P.Respawned.connect(PlayerRespawn)
	print(name, " Player Connected")

func BodyEntered(Body):
	if Body.is_in_group("Player") && !Activated:
		Activated = true
		PreviousCheckpoint = Body.Checkpoint
		Body.Checkpoint = self
		$Sprite.frame = 1
		Body.GotCheckpoint.emit(self)

func Use(By):
	By.position = global_position + Vector2(4,0)
	Lives -= 1
	if Lives == 0:
		By.Checkpoint = PreviousCheckpoint
	$Sprite.frame = 4 - Lives

func PlayerRespawn(Checkpoint):
	if Checkpoint == null:
		Lives = 3
		Activated = false
		$Sprite.frame = 0
