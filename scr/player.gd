extends CharacterBody2D

const explode_scene = preload("res://scene/explode.tscn")
@export var ui_used = false
var ui_centre = Vector2.ZERO
var ui_radius = 100

signal fail


var enable_shiftting = true
var inside_dots:Array[Area2D]

var out_position:Vector2 = Vector2.ZERO
var loader = null
var wave_loader_ready = null
enum state_type{IDLE,PARK, ON_WAVE, HITED}
var state = state_type.IDLE
var mouse_movement = Vector2.ZERO

var fix_angle = INF
var mouse_angle = 0

var last_position = Vector2.ZERO
var movement = Vector2.ZERO

func _ready() -> void:
	if ui_used:
		$detector.monitorable = false
		$detector.monitoring = false
		$wave_dot_detector.collision_mask = 0
		$Collision.set_deferred("disabled",true)


func _physics_process(delta: float) -> void:
	if ui_used:
		mouse_movement = Input.get_last_mouse_velocity()
		if mouse_movement.length() > 2.0:
			var dir = -Vector2.from_angle(mouse_angle).orthogonal().dot(mouse_movement)
			mouse_angle = fposmod(mouse_angle + Global.sensitivity * dir / ui_radius, TAU)
		rotation = mouse_angle+PI/2
		position = ui_centre+ui_radius*Vector2.from_angle(mouse_angle)
	if !Global.time_scale or !loader:
		return
	if !wave_loader_ready:
		modulate = Color.WHITE
		$bottom.scale = Vector2.ONE*0.15
		$surf.scale = Vector2.ONE*0.15
	movement = position - last_position
	last_position = position

	mouse_movement = Input.get_last_mouse_velocity()
	if state == state_type.ON_WAVE:
		if mouse_movement.length() > 2.0:
			var dir = -Vector2.from_angle(mouse_angle).orthogonal().dot(mouse_movement)
			mouse_angle = fposmod(mouse_angle + Global.sensitivity * dir / loader.get_radius() if loader.get_radius() else 1, TAU)
		if fix_angle != INF:
			mouse_angle = fix_angle
		rotation = mouse_angle+PI/2
		mouse_angle = loader.set_player_angle(mouse_angle)
		position = out_position + loader.centre+loader.get_radius()*Vector2.from_angle(mouse_angle)
	elif state == state_type.PARK:
		rotation = 0
		position = out_position + loader.position
	reset_physics_interpolation()
	if !$wave_dot_detector.has_overlapping_areas() or state == state_type.HITED or state == state_type.PARK or !enable_shiftting:
		wave_loader_ready = null
		return
	inside_dots = $wave_dot_detector.get_overlapping_areas()
	var unattached = true
	var now_id = loader.get_id()
	for i in inside_dots:
		if i.id == now_id:
			continue
		unattached = false
		modulate = Color.RED
		$bottom.scale = Vector2.ONE * 0.18
		$surf.scale = Vector2.ONE * 0.18
		if wave_loader_ready != i.get_wave():
			await ready_loader_changed(i.get_wave())
	if unattached:
		wave_loader_ready = null

var is_shift_able = true
var shift_delay_phase = false
func _on_shift():
	if is_shift_able and wave_loader_ready and (state == state_type.ON_WAVE or state == state_type.IDLE) and loader:

		var explode = explode_scene.instantiate()
		Global.wave_root.add_child(explode)
		explode.position = position
		$delay_shift_timer.stop()
		is_shift_able = false
		shift_delay_phase= false
		$shift.play()
		loader.is_player_on_me = false
		wave_loader_ready.is_player_on_me = true
		loader = wave_loader_ready
		wave_loader_ready = null

		mouse_angle = (position - loader.centre).angle() if (position - loader.centre).angle()>0 else 2 * PI + (position - loader.centre).angle()
		loader.player_located_angle = mouse_angle
		$disable_timer.start()
	elif is_shift_able and (state == state_type.ON_WAVE or state == state_type.IDLE) and loader:
		shift_delay_phase = true
		$delay_shift_timer.start()

func _on_delay_shift_timer_timeout() -> void:
	is_shift_able = false
	shift_delay_phase = false
	$invalid.play()
	shake($surf)
	shake($bottom)
	$disable_timer.start()



func _on_disable_timer_timeout() -> void:
	is_shift_able = true


func ready_loader_changed(NewLoader):
	wave_loader_ready = NewLoader
	if shift_delay_phase:
		await _on_shift()


func _on_detector_area_entered(area: Area2D) -> void:

	if state == state_type.HITED or state == state_type.PARK:
		return

	if area.is_in_group("park"):
		area._on_player_landed(self)
		loader_changed(area)

func loader_changed(newloader, angle: float = INF):
	if ui_used:
		mouse_angle = deg_to_rad(angle)

		#ani
		$surf.play("park_to_orbit")
		await $surf.animation_finished
		$bottom.show()
		$surf.play("orbiting_idle")

	elif newloader.is_in_group("park"):
		state = state_type.PARK
		if loader:
			loader.is_player_on_me = false
		wave_loader_ready = null
		loader = newloader.get_parent()


		#ani
		$surf.play("orbit_to_park")
		$bottom.hide()
		await $surf.animation_finished
		$surf.play("park_idle")
		#sound

	elif newloader is Wave:
		newloader.is_player_on_me = true
		state = state_type.ON_WAVE
		loader = newloader
		mouse_angle = deg_to_rad(angle)

		#ani
		$surf.play("park_to_orbit")
		await $surf.animation_finished
		$bottom.show()
		$surf.play("orbiting_idle")

func reverse():
	if state != state_type.ON_WAVE or !loader:
		$invalid.play()
		return

	if !loader.is_angle_available(fposmod(PI + mouse_angle,TAU)):
		$invalid.play()
		shake($surf)
		shake($bottom)
		return
	wave_loader_ready = null

	Global.time_scale = 0
	$reverse.play()
	await _on_vanish()

	if state != state_type.ON_WAVE or !loader:
		$reverse.stop()
		$invalid.play()
		return
	mouse_angle = fposmod(PI + mouse_angle,TAU)
	loader.player_located_angle = mouse_angle
	loader.player_located_line = loader.reset_player_located_line()

	position = loader.centre+loader.get_radius()*Vector2.from_angle(mouse_angle)
	rotation = mouse_angle+PI/2
	await _on_back()

	Global.time_scale = 1


func _on_vanish():
	$detector.set_deferred("monitoring", false)
	$bottom.hide()
	$surf.play("fail")
	await $surf.animation_finished

func _on_fail():
	if state == state_type.ON_WAVE and loader:
		loader.is_player_on_me = false
	wave_loader_ready = null
	loader = null
	state = state_type.HITED
	collision_layer = 0
	collision_mask = 0
	var t = create_tween().set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	t.tween_property(self,"position",position-movement.normalized()*150,0.7)
	_on_vanish()
	await t.finished
	state = state_type.IDLE

func _on_back():


	$appear.play()
	$surf.play("back")
	await $surf.animation_finished
	$surf.play("orbiting_idle")
	$bottom.show()
	set_collision_layer_value(1,true)
	set_collision_mask_value(32,true)
	$detector.set_deferred("monitoring", true)


func shake(object: Node2D, intensity: float = 20.0, duration: float = 0.2) -> void:
	var tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT).set_parallel()

	tween.tween_property($surf,"modulate",Color.RED,0.3*duration)
	# 初始摇晃（强度较大）
	tween.tween_property(object, "position", Vector2.RIGHT * intensity, duration * 0.2)
	tween.set_parallel(false)
	tween.tween_property(object, "position", Vector2.LEFT * intensity, duration * 0.2)

	tween.tween_property(object, "position", Vector2.RIGHT * (intensity * 0.6), duration * 0.15)
	tween.tween_property(object, "position", Vector2.LEFT * (intensity * 0.3), duration * 0.15)
	tween.tween_property(object, "position", Vector2.RIGHT * (intensity * 0.1), duration * 0.1)
	# 最终复位
	tween.tween_property(object, "position", Vector2.ZERO, duration * 0.2)
	tween.set_parallel(true)
	tween.tween_property($surf,"modulate",Color.WHITE,0.3*duration)

func _on_detector_area_exited(area: Area2D) -> void:
	pass



func _on_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("obstacle") and !body.get_parent().is_player_friendly:
		var explode = explode_scene.instantiate()
		explode.modulate = Color.RED
		Global.wave_root.add_child(explode)
		explode.position = position
		fail.emit()
