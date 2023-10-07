extends CharacterBody2D


const SPEED = 500.0


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
func deleteProjectileRpc():
	queue_free()




func _on_wave_hit_box_area_entered(hitBox):
	if not is_multiplayer_authority(): return
	var hit_name = hitBox.name;
	if hit_name == "PlayerHitBox":
		print(hit_name)
		deleteProjectileRpc.rpc()


		


func _on_wave_hit_box_body_entered(body):
	if not is_multiplayer_authority(): return
	var hit_name = body.name;
	if hit_name == "Ground":
		deleteProjectileRpc.rpc()
