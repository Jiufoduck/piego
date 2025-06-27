extends RigidBody2D
signal triggered
@export var is_father = false

var exception_arr:Array[int]

func _ready() -> void:
	if is_father:
		$Icon.hide()

func set_layer(layer:int):
	set_collision_layer_value(layer,true)
	match layer:
		17:
			$layer.texture = preload("res://pic/new-orbit/frame_00009.png")
		18:
			$layer.texture = preload("res://pic/new-orbit/frame_00007.png")
		19:
			$layer.texture = preload("res://pic/new-orbit/frame_00011.png")

func enter_area(wave_id:int):
	if exception_arr.has(wave_id):
		return
	animation(self)
	exception_arr.append(wave_id)
	triggered.emit()


func exit_area(wave_id:int):
	pass
#	if exception_arr.has(wave_id):
#		exception_arr.erase(wave_id)


func animation(object):
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self,"scale",Vector2.ONE*1.3,0.3)
	tween.tween_property(self,"scale",Vector2.ONE*0.8,0.3)
	tween.tween_property(self,"scale",Vector2.ONE,0.3)
	await tween.finished
