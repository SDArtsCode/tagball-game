extends CharacterBody2D

@export var id := 0

const MAX_SPEED = 400.0
const ACCEL = 10.0

var vel := Vector2.ZERO

func _physics_process(delta):
	var dir := Vector2.ZERO
	
	dir.x = Input.get_joy_axis(id, JOY_AXIS_LEFT_X)
	dir.y = Input.get_joy_axis(id, JOY_AXIS_LEFT_Y)
	
	if dir.length() > 1.0:
		velocity = lerp(velocity, dir.normalized()*MAX_SPEED, delta*ACCEL)
	else:
		velocity = lerp(velocity, dir*MAX_SPEED, delta*ACCEL)
	
	move_and_slide()
	
	
