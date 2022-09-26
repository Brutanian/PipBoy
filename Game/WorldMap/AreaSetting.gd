extends Control
class_name AreaSetting

@export var Name : String
@export var ShortName : String
@export var Colour1 : Color = Color.BLACK
@export var Colour2 : Color = Color.WHITE
@export var Colour3 : Color = Color.GREEN
@export var Colour4 : Color = Color.RED

@export var MapMusic : AudioStream
@export var LevelMusic : AudioStream

func SetPalette():
	Filter.FadePaletteToMult(Colour1,Colour2,Colour3,Colour4, 0.5)

func PlayMapMusic():
	MusicPlayer.PlayMusic(MapMusic)

func PlayLevelMusic():
	MusicPlayer.PlayMusic(LevelMusic)
