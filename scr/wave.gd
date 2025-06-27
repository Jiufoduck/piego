extends Node
class_name Wave
const line_scene = preload("res://scene/wave_line.tscn")
const dot_scene:PackedScene = preload("res://scene/wave_dot.tscn")


var add_num = 0
class WaveCollection:
	var waves: Array[Wave_dot]
var points: Array[WaveCollection]
var outside_points:Array[Wave_dot]
var line_num = 0
var is_closed = true
var maxline = 0

var centre:Vector2
var waveline_colour = Color.AQUA
var is_accelerate = false
var speed = 200
var acceleration = 0

var is_player_on_me = false
var line_angle_windows:PackedVector2Array
var player_located_line:int = -1
var player_located_angle:float = INF



func _ready() -> void:
	$Timer.wait_time = 0.8 if is_accelerate else 0.5 + 200.0/speed

var index
var dots:Array[Node]
func _process(delta: float) -> void:
	if !get_root().get_child_count():
		queue_free()
		Global.speed_list.erase(get_id())
		Global.centre_list.erase(get_id())
		return
	if Global.time_scale:
		$Timer.paused = false
	else:
		$Timer.paused = true

	if is_accelerate:
		speed += acceleration * Global.time_scale
		acceleration += 0.1 * Global.time_scale
	Global.speed_list[get_id()] = speed
	Global.centre_list[get_id()] = centre
	dots.clear()
	if outside_points.is_empty():
		$clean_timer.start()
	outside_points.clear()
	dots = get_dots()
	for i in dots:
		if i.out_sight:
			outside_points.append(i)
	index = 0
	points.clear()
	points.append(WaveCollection.new())

	for i in dots.size():
		#没断
		if dots[i].anti and dots[i].anti == dots[i-1]:
			points[index].waves.append(dots[i])
		#断了
		else:
			if is_closed and is_player_on_me:
				player_located_line = reset_player_located_line()
			is_closed = false
			points.append(WaveCollection.new())
			index+=1
			points[index].waves.append(dots[i])
		if dots[0].anti and dots[i] == dots[0].anti and points.size()>1:
			points[-1].waves.append_array(points[0].waves)
			points.pop_front()

	for ii in range(points.size()-1,-1,-1):
		if points[ii].waves.size()<3:
			for iii in points[ii].waves:
				iii.queue_free()
			points.remove_at(ii)
	if points.is_empty():
		queue_free()
		Global.speed_list.erase(get_id())
		Global.centre_list.erase(get_id())
		return


	#边缘加深
	if !is_closed:
		for i in points:
			i.waves[1].be_edge()
			i.waves[-1].be_edge()
	#获取角度区间
	line_angle_windows.clear()
	for ii in points:
		line_angle_windows.append(Vector2(ii.waves[0].direction,ii.waves[-1].direction))


	if line_num == points.size():
		for i in points.size():
			$line.get_child(i).set_point(points[i].waves.map(func(a):return a.position))
			$line.get_child(i).reload(is_closed,waveline_colour)
	#原本的波浪结构与数量变化了
	else:
		#重置玩家所处线
		if is_player_on_me:
			player_located_line = reset_player_located_line()

		var lines = $line.get_children()
		var ins
		for i in points.size():
			ins = line_scene.instantiate()
			$line.add_child(ins)
			ins.set_point(points[i].waves.map(func(a):return a.position))
			ins.reload(is_closed,waveline_colour)

		for i in lines:
			i.queue_free()
		if !line_num:
			beginning()

		line_num = points.size()
		maxline = max(line_num,maxline)

var closest_limit:float
var closest_index:int
func reset_player_located_line():
	closest_limit = INF
	closest_index = 0
	for i in line_angle_windows.size():
		if angle_in_range(player_located_angle,line_angle_windows[i].x,line_angle_windows[i].y):
			return i
		else:
			if closest_limit > abs(line_angle_windows[i].x - player_located_angle):
				closest_limit = abs(line_angle_windows[i].x - player_located_angle)
				closest_index = i
			if closest_limit > abs(line_angle_windows[i].y - player_located_angle):
				closest_limit = abs(line_angle_windows[i].y - player_located_angle)
				closest_index = i
	return closest_index


func set_player_angle(p_angle) -> float:
	if line_angle_windows.is_empty() or is_closed:
		player_located_angle = p_angle
		return player_located_angle
	if player_located_line>=line_angle_windows.size():
		player_located_line = reset_player_located_line()
	if !angle_in_range(p_angle,line_angle_windows[player_located_line].x,line_angle_windows[player_located_line].y):
		player_located_line = reset_player_located_line()
	player_located_angle = clamp_angle(p_angle,line_angle_windows[player_located_line].x,line_angle_windows[player_located_line].y)
	return player_located_angle

func is_angle_available(angle):
	for i in line_angle_windows:
		if angle_in_range(angle,i.x,i.y):
			return true
	return false

# 将角度限制在min和max范围内（弧度制）
func clamp_angle(val: float, min: float, max: float) -> float:


	# 处理跨越0点的情况
	if min > max:
		if val < min and val > max:
			# 找出离val最近的范围边界
			if abs(val - min) < abs(val - max):
				return min
			else:
				return max
	else:
		if val > max or val < min:
			# 找出离val最近的范围边界
			if abs(val - min) < abs(val - max):
				return min
			else:
				return max

	return val

func angle_in_range(angle,start_angle,end_angle):
	if start_angle < end_angle:
		return angle >= start_angle and angle <= end_angle  # 普通区间判断
	else:
		return angle >= start_angle or angle <= end_angle

func set_mask(mask):
	match mask:
		17:
			waveline_colour= Color.RED
		18:
			waveline_colour= Color.GREEN
		19:
			waveline_colour= Color.DODGER_BLUE


func beginning():
	for i in $line.get_children():
		create_tween().tween_property(i,"width",i.width,1)
		i.width = 1

func replicate_all():
	$Timer.wait_time += max(0.0,add_num - speed/1000.0)
	add_num += 1 *0.5 if is_accelerate else 1
	for i:Wave_dot in get_dots():
		i.replicate()
	$Timer.start()


func get_dots() -> Array[Node]:
	return $dot_root.get_children()

func get_root():
	return $dot_root

func get_id()->int:
	return $dot_root.get_instance_id()

func get_radius()->int:
	if get_root().get_child_count():
		return $dot_root.get_child(0).radius
	else:
		return -1


func _on_clean_timer_timeout() -> void:
	for i in outside_points:
		if is_instance_valid(i):
			i.queue_free()
	outside_points.clear()
