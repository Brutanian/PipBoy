extends Resource

@export var Index : int = 0

@export var TotalDroplets : int = 0
@export var CurrentDroplets : int = 0

@export var UnlockedWorlds : Array
@export var UnlockedLevels : Array

func _to_string():
	return str("File: ",Index,"\nW: ",WorldCount()," D: ",TotalDroplets)

func IsLevelUnlocked(LevelID : int):
	return LevelID in UnlockedLevels

func IsWorldUnlocked(WorldID : int):
	return WorldID in UnlockedWorlds

func UnlockLevel(LevelID : int):
	UnlockedLevels.append(LevelID)
	CurrentDroplets -= 1

func UnlockWorld(WorldID : int):
	UnlockedWorlds.append(WorldID)

func AddDroplet():
	TotalDroplets += 1
	CurrentDroplets += 1

func LevelCount():
	return len(UnlockedLevels)

func WorldCount():
	return len(UnlockedWorlds)
