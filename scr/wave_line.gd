extends Line2D

var curve

func _ready() -> void:
	curve= width_curve

func _process(delta: float) -> void:
	$inner_line.width = width/3

func set_point(line:PackedVector2Array):
	$inner_line.points = line
	points = line
func reload(is_close,wave_color):
	default_color = wave_color
	if get_point_count()>1:
		if is_close:
			$inner_line.closed = true
			closed = true
			$inner_line.width_curve = null
			width_curve = null
		else:
			closed = false
			$inner_line.closed = false
			width_curve = curve
			$inner_line.width_curve = curve
