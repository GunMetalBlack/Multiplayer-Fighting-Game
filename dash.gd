extends Node2D

const dash_delay = 0.4
var can_dash = true
@onready var duration_timer = $Timer
@onready var ghost_duration_timer = $GhostTimer
var ghost_scene = preload("res://DashGhost.tscn")
var sprite

func start_dash(sprite, duration):
	self.sprite = sprite
	
	duration_timer.wait_time = duration
	duration_timer.start()
	ghost_duration_timer.start()
	instance_ghost()

func instance_ghost():
	var ghost: Sprite2D = ghost_scene.instantiate()
	get_parent().get_parent().add_child(ghost)
	
	var current_frame_index = sprite.frame
	var frame = sprite.sprite_frames.get_frame_texture("default", current_frame_index)
	ghost.texture = frame
	ghost.global_position = global_position
	#ghost.texture = sprite.texture
	#ghost.vframes = sprite.vframes
	#ghost.hframes = sprite.hframes
	

func is_dashing():
	return !duration_timer.is_stopped()


func _on_ghost_timer_timeout():
	instance_ghost()

func end_dash():
	ghost_duration_timer.stop()
	can_dash = false
	await get_tree().create_timer(dash_delay).timeout
	can_dash = true


func _on_timer_timeout():
	end_dash()
