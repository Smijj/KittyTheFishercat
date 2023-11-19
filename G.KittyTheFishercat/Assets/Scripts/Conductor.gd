extends AudioStreamPlayer
class_name Conductor

signal SpawnActionBeat()
signal ActionBeat(songPositionInBeats)
signal beat(songPositionInBeats)
signal measure(songPositionInBeats)


@export_group("References")
#@export var _AudioManager: AudioManager
@export var _PlayerAnim: AnimatedSprite2D
@export var _SFX: AudioStreamPlayer

@export_group("Conductor Settings")
@export var _BPM:int = 100
@export var _Measures:int = 4
@export_range(0, 0.4) var _HitBufferPercentage:float = 0.2	#The percentage of the length of a Beat that the hit buffer covers. Cant be >= 50%

@export_group("Debug")
# Tracking the beat and song position
@export var _SongPosition:float = 0.0
@export var _SongPositionInBeats:int = 1
@export var _LastReportedBeat:int = 0
@export var _SecPerBeat = 60.0 / _BPM
var _BeatsBeforeStart:int = 0
var _Measure:int = 1

# Determining how close to an event a beat is
var _Closest = 0
var _TimeOffBeat = 0.0

# Action Beat stuff
@export var _ActionBeats := [] as Array[int]
@export var _ActionBeatSpawnIndex:int = 0
@export var _ActionBeatIndex:int = 0
var _HitBuffer:float = 0
var _HoldAnimFrame:bool = false

enum State {Default, Alert, Windup, Action, Sleep}
var _CurrentState:State = State.Default

@export_group("Sound Settings")
@export var _AlertSFX : AudioStream
@export var _WindupSFX : AudioStream
@export var _ActionSFX : AudioStream

@export_group("Fish Refs")
@export var _FishSpawnPos : Node2D
@export var _FishPrefabs := [] as Array[PackedScene]
@export var _ActiveFish := [] as Array[Node2D] 


func _ready():
	if _PlayerAnim: 
		_PlayerAnim.play("Sleep")
		_CurrentState = State.Sleep
	
	
func _on_audio_manager_song_played(songData : SongDataSO):
	InitSongData(songData)

func InitSongData(songData : SongDataSO):
	if songData == null:
		print("No SongData, Cancelling Conductor Init")
		return
	
	_LastReportedBeat = 0
	_SongPosition = 0
	_SongPositionInBeats = 0
	_SecPerBeat = 60.0 / songData._BPM
	_HitBuffer = _HitBufferPercentage * _SecPerBeat
	
	_ActionBeatSpawnIndex = 0
	_ActionBeatIndex = 0
	_ActionBeats.clear()
	
#	_ActionBeats = [5, 10, 13, 15, 17, 19, 21, 22, 23, 26, 30]
	
	var numberOfBeatsInSong:int = int(floor(songData._Song.get_length() / _SecPerBeat))
	print("Number of Beats in Song ", numberOfBeatsInSong)
	var index:int = 0
	for i in (numberOfBeatsInSong):
		if i < _Measures + 3: continue		# Dont let ActionBeats spawn to close to the start
		if randf() <= 0.65: continue		# 80% chance an Action Beat wont be set
		
		if _ActionBeats.size() > 0:
			# if the previous Beat was also an ActionBeat run in through the random chance again
			if i-1 == _ActionBeats[_ActionBeats.size()-1]:
				if randf() <= 0.50: continue		# 50% chance an ActionBeat wont be set
			
			# if the Beat before the previous Beat was an ActionBeat run in through the random chance again
			elif i-2 == _ActionBeats[_ActionBeats.size()-1]:
				if randf() <= 0.25: continue		# 25% chance an ActionBeat wont be set
			
		
		_ActionBeats.append(i as int)
		index += 1
		print("Added ActionBeat")
	
	
	GameManager.BPM = songData._BPM
	GameManager.MEASURES = _Measures
	GameManager.SONG_POSITION = _SongPosition
	GameManager.SONG_POSITION_IN_BEATS = _SongPositionInBeats
	GameManager.SEC_PER_BEAT = _SecPerBeat
	
	# Set Song then play it
	stream = songData._Song
	play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	HandleBeat()
	HandleActionBeatSpawning()
	HandleActionBeat()	# Needs to happen after HandleBeat() function otherwise some anims wont be set properly

func _on_action_button_pressed():
	if _ActionBeatIndex >= _ActionBeats.size(): return
	
	# Check if the player pressed the key within the buffer zone of the current ActionBeat TimeStamp
	var actionBeatTimeStamp = _ActionBeats[_ActionBeatIndex] * _SecPerBeat
	# LeadingBuffer: songPos >= TimeStamp - buffer
	# TrailingBuffer: songPos <= TimeStamp + buffer
	if _SongPosition >= actionBeatTimeStamp - _HitBuffer and _SongPosition <= actionBeatTimeStamp + _HitBuffer:
		# The input is successful
		
		var randomFish = _FishPrefabs[randi_range(0,_FishPrefabs.size()-1)].instantiate()
		_ActiveFish.append(randomFish)
		_FishSpawnPos.add_child(randomFish)
		
		_CurrentState = State.Action
		if (_PlayerAnim): _PlayerAnim.play("Action")
		if (_SFX and _ActionSFX): 
			_SFX.stream = _ActionSFX
			_SFX.play()
		
		_ActionBeatIndex += 1
		_HoldAnimFrame = true

func HandleActionBeatSpawning():
	if _ActionBeatSpawnIndex >= _ActionBeats.size(): return
	
	var currentActionBeat = _ActionBeats[_ActionBeatSpawnIndex]
	
	# Spawn ActionBeat if currentTime >= timestamp - travelTime
	var nextSpawnBeat:int = currentActionBeat - _Measures
	if _SongPositionInBeats >= nextSpawnBeat:
		print("ActionBeat, Song Pos: ", currentActionBeat)
		
		SpawnActionBeat.emit(currentActionBeat)
		_ActionBeatSpawnIndex += 1

func HandleActionBeat():
	if _PlayerAnim == null: return
	if _ActionBeatIndex >= _ActionBeats.size(): return
	
	var currentActionBeat = _ActionBeats[_ActionBeatIndex]
	var currentActionBeatTimeStamp = currentActionBeat * _SecPerBeat
	
	# Increment _ActionBeatIndex if the player misses the input
	if _SongPosition > currentActionBeatTimeStamp + _HitBuffer:
		_ActionBeatIndex += 1
	
	# If the current ActionBeat happens on the Beat after the last ActionBeat
	if currentActionBeat - 1 == _ActionBeats[_ActionBeatIndex-1] and _SongPositionInBeats < currentActionBeat:
		# Play the windup anim in the off beat before the current ActionBeat
		if _SongPosition >= currentActionBeatTimeStamp - _SecPerBeat/2:
			if _CurrentState == State.Windup: return
			_CurrentState = State.Windup
			
			_PlayerAnim.play("Windup")
			ClearFishObjs()
#			if (_SFX and _WindupSFX): 
#				_SFX.stream = _WindupSFX
#				_SFX.play()
	
	# Else If the current ActionBeat happens 2 Beats after the last ActionBeat
	elif currentActionBeat - 2 == _ActionBeats[_ActionBeatIndex-1] and _SongPositionInBeats < currentActionBeat:
		# Play the windup anim on the beat before the current ActionBeat
		if _SongPositionInBeats >= currentActionBeat - 1:
			if _CurrentState == State.Windup: return
			_CurrentState = State.Windup
			
			_PlayerAnim.play("Windup")
			if (_SFX and _WindupSFX): 
				_SFX.stream = _WindupSFX
				_SFX.play()
	
	# Otherwise there is at least 2 beats inbetween the ActionBeats meaning both the Alert and Windup anims can play
	else:
		if _SongPositionInBeats >= currentActionBeat - 1 and _SongPositionInBeats < currentActionBeat:
			if _CurrentState == State.Windup: return
			_CurrentState = State.Windup
			
			_PlayerAnim.play("Windup")
			if (_SFX and _WindupSFX): 
				_SFX.stream = _WindupSFX
				_SFX.play()
		elif _SongPositionInBeats >= currentActionBeat - 2 and _SongPositionInBeats < currentActionBeat:
			if _CurrentState == State.Alert: return
			_CurrentState = State.Alert
			
			_PlayerAnim.play("Alert")
			if (_SFX and _AlertSFX): 
				_SFX.stream = _AlertSFX
				_SFX.play()


func HandleBeat():
	if not playing: return
	
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
	
	# Animation
	if _PlayerAnim and not _HoldAnimFrame and _CurrentState != State.Sleep: 
		_PlayerAnim.play("Default")
		_CurrentState = State.Default
		ClearFishObjs()

	_HoldAnimFrame = false
	

func ClearFishObjs():
	for fish in _ActiveFish:
		fish.queue_free()
	_ActiveFish.clear()





