extends Area2D
@export var Pcam:PhantomCamera2D

signal spwpoint_reload(cam, is_in)


func _on_body_entered(body: Node2D) -> void:
	if Pcam.follow_mode == PhantomCamera2D.FollowMode.SIMPLE:
		Pcam.follow_target = body
	spwpoint_reload.emit(Pcam,true)



func _on_body_exited(body: Node2D) -> void:
	spwpoint_reload.emit(Pcam,false)
