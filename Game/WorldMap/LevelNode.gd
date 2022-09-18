@tool
extends PathNode

@export_group("Level Settings")
@export var Scene : PackedScene
@export var ID : int = 0

@export_subgroup("Palette")
@export var Colour1 : Color = Color.BLACK
@export var Colour2 : Color = Color.WHITE
@export var Colour3 : Color = Color.RED
@export var Colour4 : Color = Color.GREEN

func Unlocked(Instant : bool = false):
	pass

func CompleteLevel():
	Complete()


