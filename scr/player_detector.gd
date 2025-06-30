extends Area2D

var is_triggered = false
signal triggered

func _on_body_entered(body: Node2D) -> void:
	if is_triggered:
		return
	is_triggered = true
	triggered.emit()
	animation(self)

func reset():
	is_triggered = false


func animation(object):
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self,"scale",Vector2.ONE*1.3,0.3)
	tween.tween_property(self,"scale",Vector2.ONE*0.8,0.3)
	tween.tween_property(self,"scale",Vector2.ONE,0.3)
	await tween.finished
