extends Range

@export var Bus : String
@export_node_path(Label) var LabelPath : NodePath
@onready var LinkedLabel : Label = get_node(LabelPath)

func _ready():
	var NewVal : float = Settings.GetVolume(Bus)
	value = NewVal
	UpdateValue(NewVal)
	value_changed.connect(UpdateValue)

func UpdateValue(NewValue : float):
	LinkedLabel.text = "%s - %s%%" % [Bus,NewValue]
	Settings.SetVolume(Bus, NewValue)
	Settings.Apply()
