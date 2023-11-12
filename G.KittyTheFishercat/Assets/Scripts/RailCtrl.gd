extends ColorRect


@export var _IndicatorSpawnPos: Node2D
@export var _JudgementLinePos: Node2D
var RhythmIndicatorPrefab = preload("res://Assets/Prefabs/RhythmIndicator.tscn") 

var _BPM: int = 0
var _TravelTime: float = 0.0


# Called when the node enters the scene tree for the first time.
func _ready():
    # TravelTime = Measures * SecPerBeat
    _TravelTime = GameManager.MEASURES * GameManager.SEC_PER_BEAT

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    
    pass


func _on_conductor_set_bpm(bpm):
    _BPM = bpm


func SpawnIndicator():
    
    var indicatorInstance = RhythmIndicatorPrefab.instantiate()
    indicatorInstance.position = _IndicatorSpawnPos.position
    add_child(indicatorInstance)
   
    
    pass


func _on_conductor_beat(position):
    # On ActionBeat instantiate a BeatInidicator that will travel to the judgment line and meet it as the ActionBeat happens
    
    # SpawnTime = ActionBeat PositionInSong - TravelTime (-+) InputDelay
    # Spawn if Position + TravelTimeInBeats >= ActionBeat
    SpawnIndicator()
    
