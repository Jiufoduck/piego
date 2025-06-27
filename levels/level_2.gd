extends Level



func _on_fin_change_scene(angle,fin) -> void:
	$mobile_obstacle/moving_obstcl2.trigger()


func _on_start_player_contact() -> void:
	$mobile_obstacle/moving_obstcl.trigger()
