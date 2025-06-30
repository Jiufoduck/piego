extends Level


func _on_player_detector1_triggered() -> void:
	$mobile_obstacle/moving_obstcl2.trigger()
	$mobile_obstacle/moving_obstcl4.trigger()

func _on_player_detector2_triggered() -> void:
	$mobile_obstacle/moving_obstcl.trigger()
	$mobile_obstacle/moving_obstcl3.trigger()


func _on_level_start_player_contact() -> void:
	$mobile_obstacle/moving_obstcl5.trigger()



func _on_level_change_scene(fix_angle: Variant, fin: Variant) -> void:
	$mobile_obstacle/moving_obstcl6.trigger()


func reset_moving_obstc():
	$mobile_obstacle/moving_obstcl.reset()
	$mobile_obstacle/moving_obstcl2.reset()
	$mobile_obstacle/moving_obstcl3.reset()
	$mobile_obstacle/moving_obstcl4.reset()
	$passive_emitter/player_detector.reset()
	$passive_emitter/player_detector2.reset()
