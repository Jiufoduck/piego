extends Polygon2D
class_name Obstacle
@export var is_player_friendly = false
@export var is_wave_friendly = false

# 原始参数（基于设计时的参考长度）
var reference_length: float = 500.0  # 设计时的Line2D参考长度
var base_speed: float = 500.0        # 原始速度
var base_dash_size: float = 160.0    # 原始虚线长度
var base_gap_size: float = 160.0     # 原始间隔长度


func _ready() -> void:

	$collision/Collision.polygon = polygon
	if is_wave_friendly:
		color = Color.TRANSPARENT
		$virtual_edge.points = polygon
		$collision.set_collision_layer_value(32,false)
		$collision.set_collision_layer_value(31,true)
		$virtual_edge.material = $virtual_edge.material.duplicate()
		balance_shader($virtual_edge)


# 计算Line2D总长度（考虑所有线段）
func get_total_length(obj:Line2D) -> float:
	var points = obj.points
	var length = 0.0
	for i in range(points.size() - 1):
		length += points[i].distance_to(points[i + 1])
	return length

func balance_shader(obj:Line2D):
	var current_length = get_total_length(obj)
	# 计算长度比例因子
	var length_ratio = reference_length / current_length
	# 动态调整着色器参数

	obj.material.set_shader_parameter("speed", base_speed * length_ratio)
	obj.material.set_shader_parameter("dash_size", base_dash_size * length_ratio)
	obj.material.set_shader_parameter("gap_size", base_gap_size * length_ratio)


func insert_points_on_segments(poly: PackedVector2Array, points_per_unit_length = 0.005) -> PackedVector2Array:
	var new_polygon := PackedVector2Array()

	# 遍历多边形的每条边（闭合多边形）
	for i in range(polygon.size()):
		var start_point := poly[i]
		var end_point := poly[(i + 1) % poly.size()]  # 循环连接到第一个点

		new_polygon.append(start_point)  # 添加原始顶点

		var segment_length := start_point.distance_to(end_point)
		var num_points := int(segment_length * points_per_unit_length)

		# 跳过长度为0的线段或不需要插入点的情况
		if num_points <= 0 or segment_length <= 0.0:
			continue

		# 计算插入点的间隔比例
		var step := 1.0 / (num_points + 1)

		# 在线段上均匀插入点
		for j in range(1, num_points + 1):
			var t := j * step
			var new_point := start_point.lerp(end_point, t)
			new_polygon.append(new_point)

	return new_polygon
