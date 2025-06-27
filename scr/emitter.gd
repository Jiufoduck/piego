extends Node2D
const dot_scene:PackedScene = preload("res://scene/wave_dot.tscn")
const wave_scene:PackedScene = preload("res://scene/wave.tscn")

const segment = 5

@export var angle = 0
@export var angle_range = 360
@export var ini_speed:int = 200
@export var is_accelerate:bool = false
@export var mask:int = 17
@export var is_father = false

func _ready() -> void:
	reset_range()
	set_mask(mask)
	if is_father:
		$Sprite2D.hide()

func emit() -> Wave:
	var list:Array
	var new_ins:Wave_dot
	var new_wave:Wave = wave_scene.instantiate()
	new_wave.is_accelerate = is_accelerate
	new_wave.speed = ini_speed
	new_wave.centre = global_position
	new_wave.set_mask(mask)
	Global.wave_root.add_child(new_wave)
	for i in range(angle,angle+int(angle_range),segment):
		new_ins = dot_scene.instantiate()
		new_ins.direction = fposmod(deg_to_rad(i),TAU)
		new_ins.id = new_wave.get_id()
		new_ins.set_collision_mask_value(mask,true)
		if !list.is_empty():
			new_ins.anti = list.back()
		list.append(new_ins)
		new_wave.get_root().call_deferred("add_child",new_ins)
		new_ins.position = global_position
	if int(angle_range) == 360:
		list[0].anti = list.back()
	return new_wave


func set_mask(newmask:int):
	mask = newmask
	match newmask:
		17:
			$layer.texture = load("res://pic/new-orbit/frame_00010.png")
		18:
			$layer.texture = load("res://pic/new-orbit/frame_00008.png")
		19:
			$layer.texture = load("res://pic/new-orbit/frame_00012.png")

func set_angle(newangle,range):
	angle = newangle
	angle_range= range
	reset_range()

func reset_range():
	if angle_range == 360:
		return
	var line = $angle_range
	line.clear_points()
	for i in range(angle,angle+angle_range,5):
		line.add_point(Vector2.from_angle(deg_to_rad(i))*50)

func animation(object):
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self,"scale",Vector2.ONE*1.3,0.3)
	tween.tween_property(self,"scale",Vector2.ONE*0.8,0.3)
	tween.tween_property(self,"scale",Vector2.ONE,0.3)
	await tween.finished
