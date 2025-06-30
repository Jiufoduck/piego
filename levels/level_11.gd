extends Level


func _on_level_start_player_contact() -> void:
	$mobile_obstacle/moving_obstcl.trigger()


func _on_player_detector_triggered() -> void:
	$mobile_obstacle/moving_obstcl2.trigger()

func reset_moving_obstc():
	$mobile_obstacle/moving_obstcl2.reset()
	$passive_emitter/player_detector.reset()


func _on_level_change_scene(fix_angle: Variant, fin: Variant) -> void:
	$mobile_obstacle/moving_obstcl3.trigger()
