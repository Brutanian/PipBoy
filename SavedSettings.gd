extends Resource
class_name SavedSettings

@export var ColorMode : ScreenManager.Mode = 1
@export var FullScreen : bool = true
@export var VSync : bool = true
@export var ReduceEffects : bool = false

@export var InputDictionary : Dictionary = {
	"Up": [87,11],
	"Down": [83,12],
	"Left": [65,13],
	"Right": [68,14],
	"A": [32,0],
	"B": [4194325,1]
}

@export var MasterVol : int = 80
@export var MusicVol : int = 80
@export var SFXVol : int = 80

func SetAction(ActionName : String, Index : int, Keyboard : bool):
	if Keyboard:
		InputDictionary[ActionName][0] = Index
	else:
		InputDictionary[ActionName][1] = Index

func _to_string():
	return str("Saved Settings: ",ColorMode,int(FullScreen),int(VSync),int(ReduceEffects),",",MasterVol,",",MusicVol,",",SFXVol)
