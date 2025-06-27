extends Node

@export var speed = 200
@export var angle_range:int = 360
@export var start_angle:int = 0
@export var mask = 17
@export var layer = 17

func _ready() -> void:
	$reciever.set_layer(layer)
	$emitter.ini_speed = speed
	$emitter.set_mask(mask)
	$emitter.set_angle(start_angle,angle_range)

func _on_reciever_triggered() -> void:
	$emitter.animation(self)
	$reciever.exception_arr.append($emitter.emit().get_id())
