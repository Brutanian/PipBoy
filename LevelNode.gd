@tool
extends PathNode

@export_group("Level Settings")
@export var Scene : PackedScene
@export var ID : int = 0

@export_subgroup("Palette")
@export var Colour1 : Color 
@export var Colour2 : Color 
@export var Colour3 : Color 
@export var Colour4 : Color 

func Unlocked():
	pass
