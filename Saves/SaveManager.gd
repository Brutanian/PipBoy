extends Node

const SAVE_PATH : String = "res://Saves/SaveFile%s.res"

var Current : SaveFile

func LoadSave(Index : int):
	var FilePath : String = SAVE_PATH % Index
	if File.file_exists(FilePath):
		Current = load(FilePath)
	else:
		Current = SaveFile.new()
		Current.Index = Index

func GetSaveFileStr(Index : int):
	var FilePath : String = SAVE_PATH % Index
	if File.file_exists(FilePath):
		return str(load(FilePath))
	else:
		return "Empty"

func Save():
	ResourceSaver.save(Current,SAVE_PATH % Current.Index)
