extends Node2D


@export var _Conductor: Conductor

@export var _IndicatorSpawnPosLeft: Node2D
@export var _IndicatorSpawnPosRight: Node2D
@export var _IndicatorDespawnPos: Node2D
@export var BeatIndicatorPrefab = preload("res://Assets/Prefabs/BeatIndicator.tscn") 
@export var ActionBeatIndicatorPrefab = preload("res://Assets/Prefabs/ActionBeatIndicator.tscn") 

var _Indicators := [] as Array[RhythmIndicator]

var _TravelTime: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func _on_conductor_beat(songPositionInBeats):
	# On Beat instantiate a BeatInidicator that will travel to the judgment line
	SpawnIndicator(BeatIndicatorPrefab)

func _on_conductor_spawn_action_beat(songPositionInBeats):
	# On instantiate a BeatInidicator that will travel to the judgment line and meet it as the ActionBeat happens	
	SpawnIndicator(ActionBeatIndicatorPrefab)

func SpawnIndicator(prefab):
	
	# TravelTime = Measures * SecPerBeat
	_TravelTime = GameManager.MEASURES * GameManager.SEC_PER_BEAT
	
	var indicatorInstanceLeft := prefab.instantiate() as RhythmIndicator
	indicatorInstanceLeft.position = _IndicatorSpawnPosLeft.position
	add_child(indicatorInstanceLeft)
	_Indicators.append(indicatorInstanceLeft)
	indicatorInstanceLeft.MoveIndicator(_TravelTime)
	indicatorInstanceLeft._OnDestroyed.connect(RemoveIndicator.bind(indicatorInstanceLeft))
	
	var indicatorInstanceRight := prefab.instantiate() as RhythmIndicator
	indicatorInstanceRight.position = _IndicatorSpawnPosRight.position
	add_child(indicatorInstanceRight)
	_Indicators.append(indicatorInstanceRight)
	indicatorInstanceRight.MoveIndicator(_TravelTime)
	indicatorInstanceRight._OnDestroyed.connect(RemoveIndicator.bind(indicatorInstanceRight))


func RemoveIndicator(indicator : RhythmIndicator):
	var pos : int = _Indicators.find(indicator)
	if not pos == -1:
		_Indicators.remove_at(pos)



