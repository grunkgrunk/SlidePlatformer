extends CharacterBody2D


const FAST_SPEED = 500.0

const SLIDE_SPEED = 1000.0

const SLOW_SPEED = 200.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity_up = 2000.
var gravity_down = 2600.

var num_jumps = 1

var jump_buffer = 0.0
var cyote_time = 0.0
var wall_cyote_time = 0.0

var parallel_vel = 0.0

var last_x_direction = 0.

var is_in_jumper : bool= false

var is_sliding = false

var campos = Vector2()

var time_since_slide = 0.0

var air_time = 0.0

var boost_time = 0.0

var previous_animation = null


var jump_btn = "space"

var animation_finished = true


func _on_animation_finished():
	animation_finished = true
func _on_animation_changed():
	animation_finished = false
	previous_animation = $Sprite.animation

func can_destroy_glass():
	return G.rprint((abs(parallel_vel) > SLOW_SPEED) and is_sliding)


func change_animation(anim):
	var c = $Sprite.animation

	if c == 'roll' and not animation_finished and not (anim == 'jump') :
		return

	$Sprite.play(anim)

func _ready():
	$Sprite.animation_finished.connect(_on_animation_finished)
	$Sprite.animation_changed.connect(_on_animation_changed )

func _physics_process(delta):

	if Input.is_action_just_pressed("ui_down"):
		time_since_slide = 0.3
	if Input.is_action_just_released("ui_down"):
		time_since_slide = 0.0
		print("released slide")
	
	is_sliding = Input.is_action_pressed("ui_down")



	if jump_buffer > 0.0:
		jump_buffer -= delta
	if cyote_time > 0.0:
		cyote_time -= delta
	if wall_cyote_time > 0.0:
		wall_cyote_time -= delta
	if time_since_slide > 0.0:
		time_since_slide -= delta
	if boost_time > 0.0:
		boost_time -= delta

	campos.x = lerp(campos.x, sign(velocity.x)*sqrt(abs(velocity.x))*6., 0.01)

	$lookpoint.global_position = global_position + Vector2(campos.x, 0.0)
	if $Sprite.animation == "run":
		$Sprite.speed_scale = abs(velocity.x) / 100.0
	else:
		$Sprite.speed_scale = 1
	last_x_direction = sign(velocity.x) if velocity.x != 0. else last_x_direction

	if is_on_floor():
		change_animation("run")
		cyote_time = 0.2
		num_jumps = 1

	if is_on_wall():
		num_jumps = 1
		change_animation("wall_slide")
		wall_cyote_time = 0.2

	# Add the gravity.
	if not is_on_floor():
		air_time += delta
		var grav = gravity_up if velocity.y < 0 else gravity_down

		if is_on_wall():
			if Input.is_action_pressed("ui_right"):
				grav *= 0.1 if velocity.y > 0 else 1.

		elif Input.is_action_pressed(jump_btn) and velocity.y < 0.0:
			grav*= 0.3

		# elif is_sliding:
		# 	grav *= 2.5
		
		velocity.y += grav * delta
		velocity.y = clamp(velocity.y, -SLIDE_SPEED, SLIDE_SPEED)
		
	

	
	# Handle jump.

	if num_jumps > 0 and Input.is_action_just_pressed(jump_btn):
		jump_buffer = 0.1

	if jump_buffer > 0.0:
		if cyote_time > 0.0:
			if not is_sliding: 
				velocity.y = JUMP_VELOCITY
				parallel_vel = lerp(parallel_vel, FAST_SPEED*last_x_direction*1.2, 1)
			else:
				if boost_time > 0.0:
					pass
					# velocity.y = JUMP_VELOCITY*1.
					# print("slidejump")
					# parallel_vel = lerp(parallel_vel, SLIDE_SPEED*last_x_direction*2,1)
				else:
					velocity.y = JUMP_VELOCITY
					print("failed slidejump")
					#parallel_vel = lerp(parallel_vel, SLOW_SPEED*last_x_direction, 1)

			$Sprite.speed_scale = 3
			change_animation("jump")
			$Sprite.frame = 0



		elif wall_cyote_time > 0.0:			
			$Sprite.speed_scale = 1
			change_animation("jump")
			$Sprite.frame = 0



			var wall_normal = get_wall_normal()

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
			change_animation("jump")
			$Sprite.frame = 0
			num_jumps -= 1
				
	
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")

	if direction and not is_sliding:
		$Sprite.flip_h = parallel_vel > 0
		parallel_vel = lerp(parallel_vel, direction * FAST_SPEED, 0.1)
	else:
		if is_sliding:
			if is_on_floor():
				if time_since_slide > 0.0 and air_time > 0.8: #and abs(parallel_vel) > SLOW_SPEED*1.1 and boost_time <= 0.0:
					# parallel_vel = lerp(parallel_vel, SLIDE_SPEED*last_x_direction*10, 10000*delta)
					boost_time = 0.15					
					print("rolling time")

				if get_floor_normal().y > -0.9:
					parallel_vel = lerp(parallel_vel, SLIDE_SPEED*last_x_direction, 0.1)
					change_animation("slide")
				else:
					if boost_time > 0.0:
						#if $Sprite.animation != "slide":
						#	print("boost")
						change_animation("roll")
						parallel_vel = lerp(parallel_vel, SLIDE_SPEED*last_x_direction, 1)
					else:
						parallel_vel = lerp(parallel_vel, SLOW_SPEED*last_x_direction, 0.1)
						change_animation("slide")

			else:
				if boost_time > 0.0:
					parallel_vel = lerp(parallel_vel, SLIDE_SPEED*last_x_direction,0.1)
		else:
			parallel_vel = lerp(parallel_vel, SLOW_SPEED*last_x_direction,0.1)

	# Update the velocity if on floor
	if is_on_floor() and jump_buffer <= 0.0:
		var floor_dir = get_floor_normal().rotated(PI/2)

		var vel_size = parallel_vel
		# rotate the velocity to the floor normal
		velocity = floor_dir.normalized() * vel_size
	else:
		velocity.x = parallel_vel

	if is_on_floor():
		air_time = 0.0

	var collision_happened = move_and_slide()
	if collision_happened:

		var b = get_last_slide_collision().get_collider()
		if b.is_in_group("glass_wall"):
			if can_destroy_glass():
				b.destroy()
			else:
				parallel_vel = -parallel_vel * 2




func Pickup():
	G.Pickup()
