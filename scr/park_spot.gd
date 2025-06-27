extends Area2D
@export var collision:Shape2D:
	set(val):
		collision = val
		$CoShape.shape = val
signal player_landed(player:Node2D)


func _ready() -> void:
	$CoShape.shape = collision

func _on_player_landed(p):
	land_audio()
	player_landed.emit(p)


func land_audio():
	$LandTimer.start()
	await $LandTimer.timeout
	$land_1.play()
	$ring_1.play()
	$LandTimer.start()
	await $LandTimer.timeout
	$land_2.play()
	$ring_2.play()
	$LandTimer.start()
	await $LandTimer.timeout
	$land_1.play()
	$ring_1.play()
	$LandTimer.start()
	await $LandTimer.timeout
	$land_2.play()
	$ring_2.play()
