extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var tween = get_tree().create_tween()
	
	#Sets transition and ease for all following tweens
	tween.set_trans(Tween.TRANS_QUART) 

	tween.set_ease(Tween.EASE_OUT)

	#Tween to execute, 

	tween.tween_property(self,"modulate:a",0.0,2)
	# Extra: In my case I added this callback to a function named "finished", I leave it here in case you need to call a function when the upper tweens finish.

	tween.tween_callback(finished)
	
func finished():
	queue_free()
