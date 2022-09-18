extends Control

@export_group("Palette")
@export var MenuColour1 : Color
@export var MenuColour2 : Color
@export var MenuColour3 : Color
@export var MenuColour4 : Color

var SavedPalette : PackedColorArray

enum {AUDIO,VIDEO,CONTROL}

var OnWorldMap : bool = false
var InLevel : bool = false
var MapScene : WorldMap

var SelectedSave : int = 0

var PageOpen : Control

func _ready():
	SettingsSection(VIDEO)
	OpenPage($Main, 1)
	SetPalette(0.5)

func StartLevel():
	InLevel = true
	OnWorldMap = false

func FinishLevel():
	InLevel = false
	OnWorldMap = true

func OpenPage(PageNode : Control, FocusChild : int = -1):
	for c in get_children():
		c.visible = c == PageNode
	if FocusChild != -1:
		PageNode.get_child(FocusChild).grab_focus()
	PageOpen = PageNode

func _input(event):
	if OnWorldMap and Input.is_action_just_pressed("Start"):
		Pause()

func OpenSettings():
	OpenPage($Settings)
	Settings.Load()
	$%FullScreen.button_pressed = Settings.Current.FullScreen
	$%VSync.button_pressed = Settings.Current.VSync
	$%ReduceEffects.button_pressed = Settings.Current.ReduceEffects
	$%ColorMode.ForceSelect(Settings.Current.ColorMode)
	SettingsSection(VIDEO)

func Back():
	if PageOpen == $SaveFileOptions:
		OpenPage($SaveFileSelect, 1)
	elif PageOpen == $SaveFileSelect:
		OpenPage($Main, 1)
	elif PageOpen == $SaveConfirm:
		OpenPage($MapPause, 3)
	elif PageOpen == $Settings:
		if OnWorldMap:
			OpenPage($MapPause, 1)
		elif InLevel:
			OpenPage($LevelPause, 1)
		else:
			OpenPage($Main, 2)
		Settings.Save()

func SettingsSection(Section : int):
	$%VideoSection.visible = Section == VIDEO
	$%Video.button_pressed = Section == VIDEO
	$%Video.focus_mode = int(Section != VIDEO) * 2
	$%AudioSection.visible = Section == AUDIO
	$%Audio.button_pressed = Section == AUDIO
	$%Audio.focus_mode = int(Section != AUDIO) * 2
	$%ControlSection.visible = Section == CONTROL
	$%Control.button_pressed = Section == CONTROL
	$%Control.focus_mode = int(Section != CONTROL) * 2
	match Section:
		VIDEO:
			$%Control.grab_focus()
		AUDIO:
			$%Video.grab_focus()
		CONTROL:
			$%Video.grab_focus()

func Exit():
	Settings.Save()
	get_tree().quit()

func SetFullscreen(New : bool):
	Settings.Current.FullScreen = New
	Settings.Apply()

func SetVSync(New : bool):
	Settings.Current.VSync = New
	Settings.Apply()

func SetReduceEffects(New : bool):
	Settings.Current.ReduceEffects = New
	Settings.Apply()

func SetColorMode(New : int):
	Settings.Current.ColorMode = New
	Settings.Apply()

func Play():
	OpenPage($SaveFileSelect, 1)

func Pause():
	OpenPage($MapPause, 1)
	visible = true
	MapScene.process_mode = Node.PROCESS_MODE_DISABLED
	MapScene.visible = false
	SetPalette()

func Resume():
	if OnWorldMap:
		MapScene.process_mode = Node.PROCESS_MODE_ALWAYS
		MapScene.visible = true
	elif InLevel:
		MapScene.CurrentLevel.process_mode = Node.PROCESS_MODE_ALWAYS
		MapScene.CurrentLevel.visible = true
	visible = false
	ReturnPalette()

func MainMenu():
	OpenPage($SaveConfirm, 1)

func SaveConfirm(Save : bool = true):
	OpenPage($Main, 1)
	
	MapScene.queue_free()
	OnWorldMap = false

func SetPalette(FadeTime : float = 0.0):
	SavedPalette = [
		Filter.GetPaletteColour(0), Filter.GetPaletteColour(1),
		Filter.GetPaletteColour(2), Filter.GetPaletteColour(3)
	]
	Filter.FadePaletteToMult(MenuColour1,MenuColour2,MenuColour3,MenuColour4,FadeTime)

func ReturnPalette(FadeTime : float = 0.0):
	Filter.FadePaletteToMult(SavedPalette[0],SavedPalette[1],SavedPalette[2],SavedPalette[3],FadeTime)

func SaveFileSelect(Index : int = -1):
	OpenPage($SaveFileOptions, 1)
	SelectedSave = Index

func EraseSave():
	OpenPage($SaveFileSelect, 1)

func PlaySave():
	var NewGame = load("res://WorldMap.tscn").instantiate()
	MapScene = NewGame
	get_tree().root.add_child(MapScene)
	visible = false
	OnWorldMap = true

