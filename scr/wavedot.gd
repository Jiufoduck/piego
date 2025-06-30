extends Area2D
class_name Wave_dot

const dot_scene:PackedScene = preload("res://scene/wave_dot.tscn")

var id
var anti:Wave_dot
var direction:float
var direction_vec:Vector2
var radius:float

func _ready() -> void:
	direction_vec = Vector2.from_angle(direction)

func _physics_process(delta: float) -> void:
	out_sight = !$VisibleOnScreenNotifier2D.is_on_screen()
	if !Global.centre_list.has(id):
		return
	if Global.time_scale and Global.speed_list.has(id):
		radius += Global.speed_list[id]*delta
		position += direction_vec*Global.speed_list[id]*delta

var new_dir
var new_ins
func replicate():
	if !Global.centre_list.has(id) and !$VisibleOnScreenNotifier2D.is_on_screen():
		return
	if anti and is_instance_valid(anti):
		new_ins = dot_scene.instantiate()
		new_dir = angle_median(anti.direction,direction)
		new_ins.direction = new_dir
		new_ins.radius = radius
		new_ins.anti = anti
		new_ins.id = id
		new_ins.collision_mask = collision_mask
		new_ins.out_sight = out_sight
		anti.add_sibling(new_ins)
		anti = new_ins

		new_ins.position = Global.centre_list[id] + Vector2.from_angle(new_dir)*radius
		return new_ins


var has_been_edge = false
func be_edge(is_anti, passdown_num = 0):
	if has_been_edge:
		return
	has_been_edge = true
	if out_sight or passdown_num>2:
		return
	if is_anti:
		var ins:Wave_dot = await replicate()
		ins.be_edge(is_anti, passdown_num+1)
	else:
		await replicate()
		be_edge(is_anti, passdown_num+1)

func angle_median(angle1: float, angle2: float) -> float:
	angle1 = fposmod(angle1, TAU)
	angle2 = fposmod(angle2, TAU)
	var average = (angle1 + angle2) / 2.0
	if abs(angle1 - angle2) > PI:
		average = fposmod(average + PI, TAU)
	return average


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("obstacle"):
		queue_free()
	if body.is_in_group("receiver"):
		body.enter_area(id)


func get_wave():
	return get_parent().get_parent()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("receiver"):
		body.exit_area(id)


func _on_timer_timeout() -> void:
	out_sight = not $VisibleOnScreenNotifier2D.is_on_screen()

var out_sight = false
