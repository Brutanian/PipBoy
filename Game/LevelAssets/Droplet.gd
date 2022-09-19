extends Area2D


func BodyEntered(body):
	if body.is_in_group("Player"):
		get_parent().LevelComplete()
