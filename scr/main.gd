extends Node2D

var level_array:Array[String] = [
"res://levels/level_0.tscn",
"res://levels/level_1.tscn",
"res://levels/level_2.tscn",
"res://levels/level_3.tscn",
"res://levels/level_4.tscn",
"res://levels/level_5.tscn",
"res://levels/level_6.tscn",
"res://levels/level_7.tscn",
"res://levels/level_8.tscn",
"res://levels/level_9.tscn",
"res://levels/level_10.tscn",
"res://levels/level_11.tscn",
"res://levels/level_end.tscn"

]
var test = 0
var level_index = 0
var next_scene:PackedScene

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	level_display("Level_0")
	Global.wave_root = $wave_root
	if test:
		change_levels(test)



var moving = false
func _process(delta: float) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		get_viewport().warp_mouse(get_viewport().size / 2)
	$movement.set_point_position(1,$cam_centre.mouse_movement/3)
	$movement.position = $cam_centre.position
	if moving:
		var offset = Input.get_last_mouse_velocity()
		$cam_centre.out_position += (offset.normalized()*clamp(offset.length()-400,0,800)/get_viewport_rect().size*100)
		$cam_centre.move_and_slide()



func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		get_viewport().warp_mouse(get_viewport().size / 2)
	if event.is_action_pressed("menu"):
		if $UI/menu.is_on:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			$UI/menu.fade()
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			$UI/menu.appear(level_index)
	if $UI/menu.is_on:
		return

	#if event.is_action_pressed("moving"):
	#	moving = not moving
	if event.is_action_pressed("reverse") and $cam_centre.loader and $cam_centre.loader is Wave:
		if Global.time_scale == 1.0:
			$cam_centre.reverse()
	if event.is_action_pressed("emit"):
		get_level().active_emitters_emit()

	if event.is_action_pressed("switch"):
		$cam_centre._on_shift()
	#if event.is_action_pressed("pause"):
	#	if Global.time_scale:
	#		Global.time_scale = 0
	#		Engine.time_scale = 0
	#	else:
	#		Engine.time_scale = 1
	#		Global.time_scale = 1


func _on_cam_centre_fail() -> void:
	Global.time_scale = 0
	$Fail.play()
	get_level().reset_moving_obstc()
	await $cam_centre._on_fail()

	wave_clear()
	$cam_centre.position = get_level().get_spw_point()
	$cam_centre.rotation = 0
	$cam_centre._on_back()
	Global.time_scale = 1

func wave_clear():
	for i in $wave_root.get_children():
		i.queue_free()

func get_level():
	if $level_root.get_child_count():
		return $level_root.get_child($level_root.get_child_count()-1)
	else:
		print("加载失败")

func _on_scene_changed(fix_angle,fin):
	level_index+=1
	if level_array.size() == level_index:
		return
	$cam_centre.enable_shiftting = false
	$cam_centre.fix_angle = deg_to_rad(fix_angle)
	if fin:
		fin.landed_callback()
		get_level().fin_callback()

	next_scene = load(level_array[level_index])
	var new_ins = next_scene.instantiate()
	level_display(new_ins.name)
	$level_root.add_child(new_ins)
	new_ins.connect("change_scene",_on_scene_changed)


	await get_tree().create_timer(0.5).timeout

	$cam_centre.fix_angle = INF

func change_levels(level_ind):
	if level_index == level_ind:
		return
	get_level().fin_callback(true)
	level_index = level_ind
	next_scene = load(level_array[level_index])
	var new_ins = next_scene.instantiate()
	$level_root.add_child(new_ins)
	new_ins.connect("change_scene",_on_scene_changed)
	$cam_centre.loader = null
	$cam_centre.state = $cam_centre.state_type.IDLE
	$cam_centre.position =  get_level().get_spw_point()
	level_display(new_ins.name)


func _on_wave_root_child_entered_tree(node: Node) -> void:
	Global.wave_count = $wave_root.get_child_count()


func _on_wave_root_child_exiting_tree(node: Node) -> void:
	Global.wave_count = $wave_root.get_child_count()


func _on_main_finished() -> void:
	$main.play()

var tween:Tween
func level_display(text):
	if tween and tween.is_running():
		tween.kill()
	%ColorRect.modulate = Color(0,0,0,0)
	%Level_display.text = text

	tween = create_tween()
	tween.tween_property(%ColorRect,"modulate",Color.WHITE,0.5)
	tween.tween_interval(2)
	tween.tween_property(%ColorRect,"modulate",Color(0,0,0,0),0.5)
