extends Node2D
class_name Level
signal change_scene(f_angle,fin)

var is_over = false

func active_emitters_emit():
	var valid = false
	if Global.wave_count<20:
		for i in $active_emitters.get_children():
			#if i != $active_emitters/level_start:
				if i.emit():
					valid = true
	if valid:
		$emit.play()
	else:
		$invalid_emit.play()


func _on_level_fin_change_scene(angle,fin) -> void:
	change_scene.emit(angle,fin)

func fin_callback():
	if !is_over:
		is_over = true
		await get_tree().create_timer(3).timeout
		queue_free()


func _on_spawnpoint_spwpoint_reload(cam: PhantomCamera2D, is_in: Variant) -> void:
	if is_in:
		cam.priority = 2
	else:
		cam.priority = 0


func get_spw_point():
	return $active_emitters/level_start.position
