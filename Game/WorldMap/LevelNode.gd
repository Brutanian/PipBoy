extends PathNode
class_name LevelNode

@export_group("Level Settings")
@export var Name : String
@export var Scene : PackedScene
@export var ID : int = 0
@export var NodeIcon : Texture2D = preload("res://Textures/MapLevel.png")
@export_node_path(PathNode) var HiddenExit : NodePath

@export_subgroup("Palette")
@export var Colour1 : Color = Color.BLACK
@export var Colour2 : Color = Color.WHITE
@export var Colour3 : Color = Color.RED
@export var Colour4 : Color = Color.GREEN

func Unlock(Instant : bool = false):
	Unlocked = true
	get_parent().AddLevelTile(floor(position / GRID_SIZE), self)
	queue_redraw()

func CompleteLevel(Hidden : bool = false):
	Complete()
	EndLevel()
	DecorVis()
	SaveManager.Current.CompleteLevel(ID)

func EndLevel():
	pass

func PlayLevel():
	get_parent().DisablePlayer()
	Filter.DitherOut(PlayLevelTrig)

func PlayLevelTrig():
	Filter.DitherIn()
	print("Playing Level [Node: %s]" % name)
	var NewLevel = Scene.instantiate()
	NewLevel.Complete.connect(CompleteLevel)
	NewLevel.Lost.connect(EndLevel)
	get_tree().root.add_child(NewLevel)
	get_parent().StartedLevel(self, NewLevel)
	Filter.FadePaletteToMult(Colour1,Colour2,Colour3,Colour4,0.5)

func _draw():
	if Unlocked:
		var IconSize : Vector2 = NodeIcon.get_size() * Vector2(0.5,1)
		if Completed:
			draw_texture_rect_region(NodeIcon, Rect2(IconSize * -0.5,IconSize), Rect2(Vector2(IconSize.x,0),IconSize))
		else:
			draw_texture_rect_region(NodeIcon, Rect2(IconSize * -0.5,IconSize), Rect2(Vector2(),IconSize))
