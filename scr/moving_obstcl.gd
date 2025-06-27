extends Obstacle

@export var motion:Vector2
var triggered = false

func trigger():
	if !triggered:
		create_tween().tween_property(self,"position",position+motion,0.1)
		triggered = true
