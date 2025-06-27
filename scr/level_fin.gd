extends Node2D

@export var fix_angle = 0
signal change_scene(fix_angle,fin)

var landed_player

func _ready() -> void:
	$emitter.set_angle(fix_angle-15,35)

func _on_park_spot_player_landed(player: Variant) -> void:
	await animation()
	landed_player = player
	$emit.play()
	change_scene.emit(fix_angle,self)

func landed_callback():
	var wave:Wave = await $emitter.emit()
	landed_player.loader_changed(wave, fix_angle)

func animation():
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self,"scale",Vector2.ONE*0.7,0.5)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self,"scale",Vector2.ONE*1.3,0.1)
	await tween.finished
