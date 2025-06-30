extends Level

func _on_fin_change_scene(fix_angle: Variant, fin: Variant) -> void:

	var tween = create_tween()
	tween.tween_property($CanvasLayer/ColorRect,"modulate",Color.WHITE,1)
	await tween.finished
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$CanvasLayer/ColorRect/VBoxContainer/Button.mouse_filter = $CanvasLayer/ColorRect.MOUSE_FILTER_STOP

func _on_button_pressed() -> void:
	$CanvasLayer/ColorRect.hide()
