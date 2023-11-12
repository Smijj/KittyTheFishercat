extends Node2D

var _TravelTime: float = 0.0

func _ready():
	_TravelTime = GameManager.MEASURES * GameManager.SEC_PER_BEAT
	
	modulate.a = 0
	
	var tween = get_tree().create_tween()
	# Tweens the Alpha to fade in the indicator
	tween.tween_property(self, "modulate:a", 1, 0.5)
	
	MoveIndicator()


# Moves indicator to the Judgment Line then deletes it using a tween (doesn't need to be called in an update loop)
func MoveIndicator():
	var tween = get_tree().create_tween()

	# tweens the position, 0 should be the JudgmentLine Pos, 1 should be the TravelTime
	tween.tween_property(self, "position", Vector2(0, 0), _TravelTime)
	#tween.tween_property(self, "position", , _TravelTime)

	# This will delete the object when it reaches the location
	tween.tween_callback(queue_free)
