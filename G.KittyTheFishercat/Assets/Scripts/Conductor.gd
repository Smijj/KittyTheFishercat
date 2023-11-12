extends AudioStreamPlayer

@export_group("Conductor Settings")
@export var _BPM: int = 100
@export var _Measures: int = 4

@export_group("Debug")
# Tracking the beat and song position
@export var _SongPosition = 0.0
@export var _SongPositionInBeats = 1
var _SecPerBeat = 60.0 / _BPM
var _LastReportedBeat = 0
var _BeatsBeforeStart = 0
var _Measure = 1

# Determining how close to an event a beat is
var _Closest = 0
var _TimeOffBeat = 0.0

signal beat(position)
signal measure(position)

#signal setBPM(bpm)

# Called when the node enters the scene tree for the first time.
func _ready():
	CalculateSongData()

func CalculateSongData():
	_SecPerBeat = 60.0 / _BPM
	
	GameManager.BPM = _BPM
	GameManager.MEASURES = _Measures
	GameManager.SONG_POSITION = _SongPosition
	GameManager.SONG_POSITION_IN_BEATS = _SongPositionInBeats
	GameManager.SEC_PER_BEAT = _SecPerBeat


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if playing:
		_SongPosition = get_playback_position() + AudioServer.get_time_since_last_mix()
		_SongPosition -= AudioServer.get_output_latency()
		_SongPositionInBeats = int(floor(_SongPosition / _SecPerBeat)) + _BeatsBeforeStart
		
		GameManager.SONG_POSITION = _SongPosition
		GameManager.SONG_POSITION_IN_BEATS = _SongPositionInBeats
		
		ReportBeat()


func ReportBeat():
	if _LastReportedBeat >= _SongPositionInBeats: return	# The beat has already been set, no need to set it again
	
	# Reset measure if its past the set number of measures
	if _Measure > _Measures:
		_Measure = 1
	
	# Invoke Events
	emit_signal("beat", _SongPositionInBeats)
	emit_signal("measure", _Measure)
	
	# Set and Increment vars
	_LastReportedBeat = _SongPositionInBeats
	_Measure += 1


func Test():
	print("Test")
	
	
	
	
	
