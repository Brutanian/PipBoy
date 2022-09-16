extends Node

func _input(event):
	if Input.is_action_just_released("ui_accept"):
		$AnimationPlayer.stop(false)
		Finish()

func Finish():
	get_tree().root.add_child(load("res://UI/MainMenu.tscn").instantiate())
	queue_free()
