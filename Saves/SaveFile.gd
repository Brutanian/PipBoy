extends Resource
class_name SaveFile

@export var Index : int = 0

@export var TotalDroplets : int = 0
@export var CurrentDroplets : int = 0

@export var UnlockedWorlds : Array
@export var CompletedLevels : Array

@export var PlayerPosition : Vector2

@export var FirstTime : bool = true

func _to_string():
	return str("File:",Index,",W:",WorldCount(),",D:",TotalDroplets)

func IsLevelComplete(LevelID : int):
	return LevelID in CompletedLevels

func IsWorldUnlocked(WorldID : int):
	return WorldID in UnlockedWorlds

func CompleteLevel(LevelID : int):
	CompletedLevels.append(LevelID)
	CurrentDroplets -= 1

func UnlockWorld(WorldID : int):
	UnlockedWorlds.append(WorldID)

func AddDroplet():
	TotalDroplets += 1
	CurrentDroplets += 1

func LevelCount():
	return len(CompletedLevels)

func WorldCount():
	return len(UnlockedWorlds)
