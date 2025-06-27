extends Level





func _on_fin_change_scene(fix_angle: Variant, fin: Variant) -> void:
	$mobile_obstacle/moving_obstcl.trigger()
