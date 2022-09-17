extends Control

@export_group("Palette")
@export var MenuColour1 : Color
@export var MenuColour2 : Color
@export var MenuColour3 : Color
@export var MenuColour4 : Color

var SavedPalette : PackedColorArray

enum {AUDIO,VIDEO,CONTROL}

var InGame : bool = false
var GameScene : Node

var SelectedSave : int = 0

var PageOpen : Control

func _ready():
	SettingsSection(VIDEO)
	OpenPage($Main, 1)
	SetPalette(0.5)

func OpenPage(PageNode : Control, FocusChild : int = -1):
	for c in get_children():
		c.visible = c == PageNode
	if FocusChild != -1:
		PageNode.get_child(FocusChild).grab_focus()
	PageOpen = PageNode

func _input(event):
	if InGame and Input.is_action_just_pressed("Start"):
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
		OpenPage($Pause, 3)
	elif PageOpen == $Settings:
		if InGame:
			OpenPage($Pause, 1)
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
	OpenPage($Pause, 1)
	visible = true
	GameScene.process_mode = Node.PROCESS_MODE_DISABLED
	GameScene.visible = false
	SetPalette()

func Resume():
	visible = false
	GameScene.process_mode = Node.PROCESS_MODE_ALWAYS
	GameScene.visible = true
	ReturnPalette()

func MainMenu():
	OpenPage($SaveConfirm, 1)

func SaveConfirm(Save : bool = true):
	OpenPage($Main, 1)
	
	GameScene.queue_free()
	InGame = false

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
	GameScene = NewGame
	get_tree().root.add_child(GameScene)
	visible = false
	InGame = true

