extends Node3D

func _ready():
	pass

func start(text: String):
	$Label3D.text = text
	var tween = create_tween()
	tween.set_parallel()
	
	tween.tween_property(self, "global_position", global_position + (Vector3.UP * 1), .3)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.chain()
	
	tween.tween_property(self, "global_position", global_position + (Vector3.UP * 8), .5)\
	.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", Vector3.ZERO, .5)\
	.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.chain()
	
	tween.tween_callback(queue_free)

	var scale_tween = create_tween()
	scale_tween.tween_property(self, "scale", Vector3.ONE * 1.5, .15)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	tween.tween_property(self, "scale", Vector3.ONE, .15)\
	.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
