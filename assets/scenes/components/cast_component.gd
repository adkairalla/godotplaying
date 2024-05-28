extends Node3D
class_name CastComponent

@onready var sprite_3d = $Sprite3D
@onready var progress_bar = $Sprite3D/SubViewport/ProgressBar
@onready var timer = $Timer

signal casting
signal casting_finished

func _ready():
	timer.timeout.connect(on_timer_timeout)

func _process(_delta):
	if timer.is_stopped():
		return
	progress_bar.value = 1 - timer.time_left / timer.wait_time
	

func cast(cast_time: float):
	if cast_time == 0:
		print("no cast time?")
		casting_finished.emit()
		return
	progress_bar.value = 0
	sprite_3d.visible = true
	timer.wait_time = cast_time
	timer.start()
	casting.emit()

func on_timer_timeout():
	sprite_3d.visible = false
	casting_finished.emit()
