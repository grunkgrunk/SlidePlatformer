extends CharacterBody2D


const FAST_SPEED = 500.0

const SLIDE_SPEED = 1000.0

const SLOW_SPEED = 200.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity_up = 2000.
var gravity_down = 2600.

var num_jumps = 2

var jump_buffer = 0.0
var cyote_time = 0.0
var wall_cyote_time = 0.0

var parallel_vel = 0.0

var last_x_direction = 0.

var is_in_jumper : bool= false

var is_sliding = false

var campos = Vector2()



func can_destroy_glass():
	return G.rprint((abs(parallel_vel) > SLOW_SPEED) and is_sliding)

func _physics_process(delta):
	is_sliding = Input.is_action_pressed("ui_down")


	if jump_buffer > 0.0:
		jump_buffer -= delta
	if cyote_time > 0.0:
		cyote_time -= delta
	if wall_cyote_time > 0.0:
		wall_cyote_time -= delta

	campos.x = lerp(campos.x, sign(velocity.x)*sqrt(abs(velocity.x))*6., 0.01)

	$lookpoint.global_position = global_position + Vector2(campos.x, 0.0)
	$Sprite.speed_scale = abs(velocity.x) / 100.0

	last_x_direction = sign(velocity.x) if velocity.x != 0. else last_x_direction

	if is_on_floor():
		$Sprite.play("run")
		cyote_time = 0.2
		num_jumps = 2

	if is_on_wall():
		num_jumps = 2
		$Sprite.play("wall_slide")
		wall_cyote_time = 0.2

	# Add the gravity.
	if not is_on_floor():
		var grav = gravity_up if velocity.y < 0 else gravity_down

		if is_on_wall():
			if Input.is_action_pressed("ui_right"):
				grav *= 0.1 if velocity.y > 0 else 1
		elif Input.is_action_pressed("ui_up") and velocity.y < 0.0:
			grav*= 0.3

		elif is_sliding:
			grav *= 2.5
		
		velocity.y += grav * delta
			


	

	
	# Handle jump.

	if num_jumps > 0 and Input.is_action_just_pressed("ui_up"):
		jump_buffer = 0.1

	if jump_buffer > 0.0 :
		

	
		if cyote_time > 0.0:
			velocity.y = JUMP_VELOCITY
			$Sprite.speed_scale = 3
			$Sprite.play("jump")
			$Sprite.frame = 0

		elif wall_cyote_time > 0.0:			
			$Sprite.speed_scale = 1
			$Sprite.play("jump")
			$Sprite.frame = 0

			var wall_normal = get_wall_normal()
		
			print('walljump')
			var lrdirection = Input.get_axis("ui_left", "ui_right")

			if sign(wall_normal.x) == sign(lrdirection):
				parallel_vel = wall_normal.x * 1000
				velocity.y = 1.3*JUMP_VELOCITY
			else:
				parallel_vel = wall_normal.x * 500
				velocity.y = JUMP_VELOCITY

		elif num_jumps > 1:
			print('doublejump')
			jump_buffer = 0.0
			velocity.y = JUMP_VELOCITY * 1.2
			$Sprite.speed_scale = 3
			$Sprite.play("jump")
			$Sprite.frame = 0
			num_jumps -= 1
				
	

	
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")

	if direction and not is_sliding:
		$Sprite.flip_h = parallel_vel > 0
		parallel_vel = move_toward(parallel_vel, direction * FAST_SPEED, 5000*delta)
	else:
		if is_sliding:
			if is_on_floor() and get_floor_normal().y > -0.9:
				parallel_vel = move_toward(parallel_vel, SLIDE_SPEED*last_x_direction, 10000*delta)
			elif is_on_floor():
				parallel_vel = move_toward(parallel_vel, SLOW_SPEED*last_x_direction, 500*delta)
		
			$Sprite.play("slide")
		else:
			parallel_vel = move_toward(parallel_vel, SLOW_SPEED*last_x_direction, 10000*delta)

	# Update the velocity if on floor
	if is_on_floor() and jump_buffer <= 0.0:
		var floor_dir = get_floor_normal().rotated(PI/2)

		var vel_size = parallel_vel
		# rotate the velocity to the floor normal
		velocity = floor_dir.normalized() * vel_size
	else:
		velocity.x = parallel_vel


	var collision_happened = move_and_slide()
	if collision_happened:

		var b = get_last_slide_collision().get_collider()
		if b.is_in_group("glass_wall"):
			if can_destroy_glass():
				b.queue_free()
			else:
				parallel_vel = -parallel_vel * 2


func Pickup():
	G.Pickup()