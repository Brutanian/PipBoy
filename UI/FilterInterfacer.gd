extends Node

func FadePaletteToMult(To1 : Color, To2 : Color, To3 : Color, To4 : Color, FadeTime : float):
	Filter.FadePaletteToMult(To1, To2, To3, To4, FadeTime)

func FadePaletteToOne(To : Color, FadeTime : float):
	Filter.FadePaletteToOne(To, FadeTime)

func FadeTo(Index : int, To : Color, FadeTime : float):
	Filter.FadeTo(Index, To, FadeTime)

func FadeFromTo(Index : int, From : Color, To : Color, FadeTime : float):
	Filter.FadeFromTo(Index, From, To, FadeTime)

func SetPaletteColour(Index : int, Colour : Color):
	Filter.SetPaletteColour(Index, Colour)
