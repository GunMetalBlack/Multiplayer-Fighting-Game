extends CharacterBody2D

const JUMP_VELOCITY = -400.0
const dash_duration = 0.2
const dash_speed = 900
var bulletImpactVelocity = 0
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var dash = $dash
@onready var sprite = $AnimatedSprite2D
@export var wave : PackedScene

func _ready():
	$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())
	if $MultiplayerSynchronizer.get_multiplayer_authority() == 1:
		var new_color = Color(1.0, 0.0, 0.0, 1.0)
		sprite.modulate = new_color
	else:
		var new_color = Color(0.0, 0.0, 5.0, 1.0)
		sprite.modulate = new_color
func _physics_process(delta):
	if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		var speed = dash_speed if dash.is_dashing() else 300.0

		# Add the gravity.
		if not is_on_floor():
			velocity.y += gravity * delta
			
		$WeaponRotation.look_at(get_viewport().get_mouse_position())
		
		#Shoot Wave
		if Input.is_action_just_pressed("Fire"):
			fire.rpc()
		
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
				if bulletImpactVelocity < 0:
					velocity.x = move_toward(velocity.x, bulletImpactVelocity, -bulletImpactVelocity)
					bulletImpactVelocity = bulletImpactVelocity + 10
				elif bulletImpactVelocity > 0:
					velocity.x = move_toward(velocity.x, bulletImpactVelocity, bulletImpactVelocity)
					bulletImpactVelocity = bulletImpactVelocity - 10
				velocity.x = move_toward(velocity.x, 0, 5)
		move_and_slide()
@rpc("any_peer","call_local")
func fire():
	var w = wave.instantiate()
	w.global_position = $WeaponRotation/WaveSpawn.global_position
	w.rotation_degrees = $WeaponRotation.rotation_degrees
	get_tree().root.add_child(w)
	
@rpc("any_peer","call_local")
func doDash():
	dash.start_dash(sprite,dash_duration)


func _on_player_hit_box_area_entered(hitBox):
	var hit_name = hitBox.name;
	if hit_name == "WaveHitBox" && !dash.is_dashing():
		print(hitBox.get_parent().transform.x[0])
		if hitBox.get_parent().transform.x[0] > 0:
			bulletImpactVelocity = 500
		else:
			bulletImpactVelocity = -500
		
