extends Level


func _on_fin_change_scene(angle,fin) -> void:
	$mobile_obstacle/moving_obstcl2.trigger()


func _on_level_start_contact() -> void:
	$mobile_obstacle/moving_obstcl.trigger()
