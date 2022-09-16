extends Label

var Focused : bool = false

var NeedInput : bool = false
@export var InitialKey : String = ""
@export var ActionName : String = ""

const JOY_NAME : Dictionary = {}

func _ready():
	SetKeybind(OS.find_keycode_from_string(InitialKey))
	focus_entered.connect(Focus)
	focus_exited.connect(Unfocus)

func _input(event):
	if Focused:
		if event is InputEventKey:
			if NeedInput:
				if Input.is_action_pressed("Start") or event.is_action_pressed("Select"):
					NeedInput = false
				else:
					SetKeybind(event.keycode)
				grab_focus()
			elif event.is_action_pressed("A") or event.is_action_pressed("Select"):
				NeedInput = true
				add_theme_color_override("font_color", Color.RED)

func SetKeybind(KeyCode : int):
	text = '"%s"' % OS.get_keycode_string(KeyCode)
	Settings.Current.SetAction(ActionName, KeyCode, true)
	Settings.Apply()

func SetButtonIndex(ButtonIndex : int):
	Settings.Current.SetAction(ActionName, ButtonIndex, false)
	Settings.Apply()

func Focus():
	Focused = true
	add_theme_color_override("font_color", Color.GREEN)
	print("Focused")

func Unfocus():
	if NeedInput:
		grab_focus()
		
	else:
		Focused = false
		add_theme_color_override("font_color", Color.WHITE)
		print("Unfocused")
