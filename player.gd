extends CharacterBody2D

const JUMP_VELOCITY = -400.0
const dash_duration = 0.2
const dash_speed = 900

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var dash = $dash
@onready var sprite = $AnimatedSprite2D

func _ready():
	$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())

func _physics_process(delta):
	if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		var speed = dash_speed if dash.is_dashing() else 300.0

		# Add the gravity.
		if not is_on_floor():
			velocity.y += gravity * delta
			
		$WeaponRotation.look_at(get_viewport().get_mouse_position())
		# Handle Jump.
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = JUMP_VELOCITY
		if Input.is_action_pressed("dash"):
			if dash.can_dash == true && !dash.is_dashing():
				doDash.rpc()
				var mouse_direction = get_local_mouse_position().normalized()
				velocity = Vector2(dash_speed * mouse_direction.x, dash_speed * mouse_direction.y)
				# Get the input direction and handle the movement/deceleration.
				# As good practice, you should replace UI actions with custom gameplay actions.
		else:
			var direction = Input.get_axis("ui_left", "ui_right")
			if direction:
				velocity.x = direction * speed
			else:
				velocity.x = move_toward(velocity.x, 0, speed)
		move_and_slide()
@rpc("any_peer","call_local")
func doDash():
	dash.start_dash(sprite,dash_duration)