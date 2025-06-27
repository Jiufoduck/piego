extends Node2D

signal player_contact
var player = null
var is_player_on_me:bool

@export var angle_window = 360
@export var angle = 0
@export var mask = 17
@export var speed = 200
@export var is_accelerate = false
@export var collision:Shape2D

func _ready() -> void:
	$emitter.set_angle(angle,angle_window)
	$emitter.set_mask(mask)
	$emitter.ini_speed = speed
	$emitter.is_accelerate = is_accelerate
	$park_spot.collision = collision

func _on_park_spot_player_landed(p: Variant) -> void:

	player = p
	is_player_on_me = true
	player_contact.emit()
	p.enable_shiftting = true

func emit():
	if player and is_player_on_me:
		is_player_on_me = false
		$emitter.animation(self)
		var wave:Wave = await $emitter.emit()
		player.loader_changed(wave,angle if angle_window == 360 else angle+angle_window/2)
		return wave
