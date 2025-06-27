extends Level




func _on_level_start_player_contact() -> void:
	$mobile_obstacle/moving_obstcl.trigger()
