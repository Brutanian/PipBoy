extends Node

const SAVE_PATH : String = "res://Saves/Settings.tres"

const DEFAULT_INPUT_MAP : Dictionary = {
	"Up": [87,11],
	"Down": [83,12],
	"Left": [65,13],
	"Right": [68,14],
	"A": [32,0],
	"B": [4194325,1]
}

var Current : SavedSettings

func _ready():
	Load()

func Save():
	ResourceSaver.save(Current, SAVE_PATH)

func Load():
	if File.new().file_exists(SAVE_PATH):
		Current = load(SAVE_PATH) as SavedSettings
		print("File Exists")
	else:
		Current = SavedSettings.new()
		print("File Doesn't Exist")
	print(Current)
	Apply()

func Apply():
	if Current:
		#Set Video
		if Current.FullScreen: #Set Fullscreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
		if Current.VSync: #Set VSync
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		else:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		
		ScreenManager.SetMode(Current.ColorMode) #Set Color Mode
		
		#Set Controls
		var InputDict : Dictionary = Current.InputDictionary
		for a in InputDict.keys():
			InputMap.action_erase_events(a)
			var Keyboard : InputEventKey = InputEventKey.new()
			var Controller : InputEventJoypadButton = InputEventJoypadButton.new()
			Keyboard.keycode = InputDict[a][0]
			Controller.button_index = InputDict[a][1]
			InputMap.action_add_event(a,Keyboard)
			InputMap.action_add_event(a,Controller)
		CopyInputEvents("Up", "ui_up")
		CopyInputEvents("Down", "ui_down")
		CopyInputEvents("Left", "ui_left")
		CopyInputEvents("Right", "ui_right")
		
		#Set Audio
		AudioServer.set_bus_volume_db(0, VolumeRemap(Current.MasterVol)) #Master Volume
		AudioServer.set_bus_volume_db(1, VolumeRemap(Current.MusicVol)) #Music Volume
		AudioServer.set_bus_volume_db(2, VolumeRemap(Current.SFXVol)) #SFX Volume

func SetVolume(Bus : String, New : int):
	match Bus:
		"Master":
			Current.MasterVol = New
		"Music":
			Current.MusicVol = New
		"SFX":
			Current.SFXVol = New

func GetVolume(Bus : String):
	match Bus:
		"Master":
			return Current.MasterVol
		"Music":
			return Current.MusicVol
		"SFX":
			return Current.SFXVol
	return 0

func VolumeRemap(Volume : float): #Remap Percentage to Decibels
	return remap(Volume, 0, 100, -80, 6)

func CopyInputEvents(FromAction : String, ToAction : String):
	InputMap.action_erase_events(ToAction)
	for e in InputMap.action_get_events(FromAction):
		InputMap.action_add_event(ToAction, e)

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		Save()
