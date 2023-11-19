extends Node
class_name AudioManager


@export var _Songs := [] as Array[SongDataSO]

var _CurrentSong : SongDataSO

signal SongPlayed(SongData)

func _ready():
	PlayNextSong()

func PlayNextSong():
	var rng:int = randi_range(0, _Songs.size()-1)
	var randomSong = _Songs[rng]
	
	if randomSong == GameManager._LastSong and _Songs.size() > 0:
		var newRng = rng + 1
		if newRng >= _Songs.size(): newRng = 0
		randomSong = _Songs[newRng]
	
	_CurrentSong = randomSong
	GameManager._LastSong = _CurrentSong
	
	print("Song Played ", _CurrentSong._SongName)
	SongPlayed.emit(_CurrentSong)



func _on_conductor_finished():
	print("Song Finished ", _CurrentSong._SongName)
	
	# Song finished, go next song
	PlayNextSong()
