extends Node2D
class_name RhythmIndicator

signal _OnDestroyed()

func _ready():
	modulate.a = 0
	
	var tween = get_tree().create_tween()
	# Tweens the Alpha to fade in the indicator
	tween.tween_property(self, "modulate:a", 1, 0.5)


# Moves indicator to the Judgment Line then deletes it using a tween (doesn't need to be called in an update loop)
func MoveIndicator(travelTime : float):
	var tween = get_tree().create_tween()

	# tweens the position, 0 should be the JudgmentLine Pos, 1 should be the TravelTime
	tween.tween_property(self, "position", Vector2(0, 0), travelTime)
	#tween.tween_property(self, "position", , _TravelTime)

	if not is_queued_for_deletion(): tween.tween_callback(ReachedDestination)

func ReachedDestination():
	_OnDestroyed.emit()
	# This will delete the object when it reaches the location
	queue_free()
