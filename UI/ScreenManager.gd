extends Node

var Fades : Array = [null,null,null,null,null]
var FilterMaterial : ShaderMaterial = load("res://UI/Filter.material")

enum Mode {ORIGINAL,LIGHT,COLOR}
enum Palette {COLOUR1,COLOUR2,COLOUR3,COLOUR4,TINT}

var CurrentMode : Mode = Mode.COLOR

var FunctionToCall : Callable

class Fade:
	var Index : Palette
	var FromColor : Color
	var ToColor : Color
	var FadeTime : float
	var CurTime : float = 0
	func _init(Ind : Palette, From : Color, To : Color, Over : float) -> void:
		Index = Ind
		FromColor = From
		ToColor = To
		FadeTime = Over
	func Advance(Delta : float) -> void:
		CurTime += Delta
	func GetColor() -> Color:
		return lerp(FromColor, ToColor, GetPercentage())
	func GetPercentage() -> float:
		return clamp(CurTime / FadeTime, 0, 1)

func FadePaletteToMult(To1 : Color, To2 : Color, To3 : Color, To4 : Color, FadeTime : float):
	FadeTo(0, To1, FadeTime)
	FadeTo(1, To2, FadeTime)
	FadeTo(2, To3, FadeTime)
	FadeTo(3, To4, FadeTime)

func FadePaletteToOne(To : Color, FadeTime : float):
	FadeTo(0, To, FadeTime)
	FadeTo(1, To, FadeTime)
	FadeTo(2, To, FadeTime)
	FadeTo(3, To, FadeTime)

func FadeTo(Index : Palette, To : Color, FadeTime : float):
	var From : Color = GetPaletteColour(Index)
	Fades[Index] = Fade.new(Index, From, To, FadeTime)

func FadeFromTo(Index : Palette, From : Color, To : Color, FadeTime : float):
	Fades[Index] = Fade.new(Index, From, To, FadeTime)

func SetPaletteColour(Index : Palette, Colour : Color):
	if Index == Palette.TINT:
		FilterMaterial.set_shader_parameter("TintColour", Colour)
	else:
		FilterMaterial.set_shader_parameter("PaletteColour" + str(Index + 1), Colour)

func GetPaletteColour(Index : Palette):
	if Index == Palette.TINT:
		return FilterMaterial.get_shader_parameter("TintColour")
	else:
		return FilterMaterial.get_shader_parameter("PaletteColour" + str(Index + 1))

func SetMode(NewMode : Mode):
	CurrentMode = NewMode
	match NewMode:
		Mode.ORIGINAL:
			FadeTo(Palette.TINT, Color(0.4, 1, 0.57), 0.5)
		Mode.LIGHT:
			FadeTo(Palette.TINT, Color.WHITE, 0.5)
		Mode.COLOR:
			FadeTo(Palette.TINT, Color.WHITE, 0.5)

func CompleteNow():
	for f in Fades:
		if f:
			SetPaletteColour(f.Index, f.ToColor)
			Fades[f.Index] = null

func _ready():
	SetPaletteColour(0, Color.BLACK)
	SetPaletteColour(1, Color.BLACK)
	SetPaletteColour(2, Color.BLACK)
	SetPaletteColour(3, Color.BLACK)

func _process(delta):
	for f in Fades:
		if f:
			f.Advance(delta)
			SetPaletteColour(f.Index, f.GetColor())
			if f.Index == Palette.TINT:
				var CurAmount : float = FilterMaterial.get_shader_parameter("TintAmount")
				var Amount : float = min(CurAmount, 1.0 - f.GetPercentage()) if CurrentMode == Mode.COLOR else max(CurAmount, f.GetPercentage())
				FilterMaterial.set_shader_parameter("TintAmount", Amount)
			if f.CurTime >= f.FadeTime:
				Fades[f.Index] = null

func DitherOut(Call : Callable = Callable()):
	FunctionToCall = Call
	$AnimationPlayer.play("Fade",-1,1.5)

func DitherIn(Call : Callable = Callable()):
	FunctionToCall = Call
	$AnimationPlayer.play("Fade",-1,-2, true)

func DitherTrigger(_AnimName):
	if FunctionToCall != null:
		FunctionToCall.call()
