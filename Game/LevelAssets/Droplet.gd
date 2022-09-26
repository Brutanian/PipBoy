extends Area2D

@export var Hidden : bool = false

func BodyEntered(body):
	if body.is_in_group("Player"):
		get_parent().LevelComplete(Hidden)
