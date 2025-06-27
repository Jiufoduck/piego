extends Control

signal level_change(level_index)

var is_on = false

var sample_centre = Vector2(1347,450)
var sample_radius = 200
var out_screen_point = Vector2(0,1080)

var main_tween:Tween

func _ready() -> void:
	%cam_centre.ui_centre = sample_centre
	%cam_centre.ui_radius = sample_radius
	var line:PackedVector2Array
	for i in 36:
		line.append(sample_centre + Vector2.from_angle(deg_to_rad(i * 10))*sample_radius)
	%wave_line.set_point(line)
	%wave_line.reload(true, Color.AQUA)

	$ColorRect.color = Color.TRANSPARENT
	$ColorRect.position = out_screen_point
	$MarginContainer.position = out_screen_point
	$sample.position = out_screen_point

func appear():
	is_on = true
	if !main_tween:
		pass
	elif main_tween.is_valid() and main_tween.is_running():
		main_tween.kill()
	main_tween = create_tween().set_parallel().set_trans(Tween.TRANS_SINE)
	%cam_centre.loader_changed(%wave_line,0)
	$ColorRect.position = Vector2.ZERO

	main_tween.tween_property($ColorRect,"color",Color(0,0,0,0.5),0.5)
	main_tween.tween_property($MarginContainer,"position",Vector2.ZERO,0.5)
	main_tween.tween_property($sample,"position",Vector2.ZERO,0.5)

func fade():
	is_on = false
	if !main_tween:
		pass
	elif main_tween.is_valid() and main_tween.is_running():
		main_tween.kill()
	main_tween = create_tween().set_parallel().set_trans(Tween.TRANS_SINE)

	main_tween.tween_property($ColorRect,"color",Color(0,0,0,0),0.5)
	main_tween.tween_property($MarginContainer,"position",out_screen_point,0.5)
	main_tween.tween_property($sample,"position",out_screen_point,0.5)
	await get_tree().create_timer(0.5).timeout
	$ColorRect.position = Vector2.ZERO


func _on_h_slider_value_changed(value: float) -> void:
	Global.sensitivity = value/100


func _on_levl_value_changed(value: int) -> void:
	%Label.text = "Level_"+ str(value)


func _on_set_button_up() -> void:
	if is_on:
		level_change.emit(%HSlider.value)
