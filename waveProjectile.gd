extends CharacterBody2D


const SPEED = 800.0


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction : Vector2

func _ready():
	direction = Vector2(1,0).rotated(rotation)

func _physics_process(delta):
	velocity = SPEED * direction
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	move_and_slide()

@rpc("any_peer","call_local")
func deleteRPC():
	queue_free()

func _on_wave_hit_box_area_entered(hitBox):
		if multiplayer.is_server():
			queue_free()
			deleteRPC.rpc()
			print("WTF")


		


func _on_wave_hit_box_body_entered(body):
	var hit_name = body.name;
	if hit_name == "Ground":
		if multiplayer.is_server():
			queue_free()
			deleteRPC.rpc()
			print("WTF")


func _on_visible_on_screen_notifier_2d_screen_exited():
		if multiplayer.is_server():
			queue_free()
			deleteRPC.rpc()
			print("WTF")
