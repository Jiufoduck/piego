extends Level




func _on_level_start_player_contact() -> void:
	$mobile_obstacle/moving_obstcl.trigger()


func _on_level_change_scene(fix_angle: Variant, fin: Variant) -> void:
	$mobile_obstacle/moving_obstcl2.trigger()
