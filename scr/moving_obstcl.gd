extends Obstacle

@export var motion:Vector2
var triggered = false
var ini_pos

func _ready() -> void:
	ini_pos = position
	super()

var tween:Tween
func trigger():
	if !triggered:
		position = ini_pos
		if tween and tween.is_running():
			tween.kill()
		tween = create_tween()
		tween.tween_property(self,"position",ini_pos+motion,0.1)
		triggered = true


func reset():
	if triggered:
		position = ini_pos + motion
		if tween and tween.is_running():
			tween.kill()
		tween = create_tween()
		tween.tween_property(self,"position",position-motion,0.1)
		triggered = false
