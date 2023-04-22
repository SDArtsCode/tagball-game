extends RigidBody2D

@export var id := 0
const MOVE_DEADZONE := 0.2
const TURN_DEADZONE := 0.5

const MAX_SPEED = 400.0
const ACCEL = 7.0

var vel := Vector2.ZERO
var turn := Vector2.ZERO
var ball_in_area : RigidBody2D = null
var ball : RigidBody2D = null

var kp : float = 0.5
var ki : float = 0.05
var kd : float = 0.9
var b_error : float = 0.0
var b_prev_error : float = 0.0
var b_pid_i : float = 0.0
var r_error : float = 0.0
var r_prev_error : float = 0.0
var r_pid_i : float = 0.0

func reset_pid():
	b_error = 0.0
	b_prev_error = 0.0
	b_pid_i = 0.0
	r_error  = 0.0
	r_prev_error = 0.0
	r_pid_i= 0.0

func drop_ball():
	reset_pid()
	ball.set_in_hands(null)
	ball = null
	set_collision_mask_value(2, true)
	
func _integrate_forces(state):
	var dir := Vector2.ZERO
	
	#dir.x = sign(Input.get_joy_axis(id, JOY_AXIS_LEFT_X)) * clamp(Input.get_joy_axis(id, JOY_AXIS_LEFT_X), 0.2, 1.0)
	#dir.y = sign(Input.get_joy_axis(id, JOY_AXIS_LEFT_Y)) * clamp(Input.get_joy_axis(id, JOY_AXIS_LEFT_Y), 0.2, 1.0)
	dir.x = Input.get_joy_axis(id, JOY_AXIS_LEFT_X)
	dir.y = Input.get_joy_axis(id, JOY_AXIS_LEFT_Y)
	turn.x = Input.get_joy_axis(id, JOY_AXIS_RIGHT_X)
	turn.y = Input.get_joy_axis(id, JOY_AXIS_RIGHT_X)
	if abs(dir.x) < MOVE_DEADZONE:
		dir.x = 0.0
	if abs(dir.y) < MOVE_DEADZONE:
		dir.y = 0.0
#	if abs(turn.x) < TURN_DEADZONE:
#		turn.x = 0.0
#	if abs(turn.y) < TURN_DEADZONE:
#		turn.y = 0.0
		
	if dir.length() > 1.0:
		linear_velocity = lerp(linear_velocity, dir.normalized()*MAX_SPEED, state.step*ACCEL)
	else:
		linear_velocity = lerp(linear_velocity, dir*MAX_SPEED, state.step*ACCEL)
	if dir.length() > TURN_DEADZONE:
		print(atan2(dir.y, dir.x))
		$Rotate.rotation = lerp_angle($Rotate.rotation, atan2(dir.y, dir.x) - PI/2, state.step*8.0)
		
	ball_in_area = null
	if $Rotate/RayCast2D.is_colliding():
		if $Rotate/RayCast2D.get_collider().is_in_group('ball'):
			ball_in_area = $Rotate/RayCast2D.get_collider()
	if Input.is_action_just_pressed("pickup"):
		if ball: # drop ball
			drop_ball()
		elif ball_in_area:
			ball = ball_in_area
			ball.set_in_hands(self)
			set_collision_mask_value(2, false)
			
	if ball != null:
		var total_error = ($Rotate/BallMarker.global_position - ball.global_position)
		var total_pid = Vector2()
		b_error = total_error.x
		if abs(b_error) > PI/96:
			var pid_p = b_error * kp
			var pid_d = kd * (b_error-b_prev_error)/state.step
			var pid_pd = pid_p + pid_d
			b_pid_i += b_error * ki
			var pid = pid_pd + b_pid_i
			total_pid.x = pid
		b_prev_error = b_error
		# R
		r_error = total_error.y
		if abs(r_error) > PI/96:
			var pid_p = r_error * kp
			var pid_d = kd * (r_error-r_prev_error)/state.step
			var pid_pd = pid_p + pid_d
			r_pid_i += r_error * ki
			var pid = pid_pd + r_pid_i
			total_pid.y = pid
		r_prev_error = r_error
		ball.apply_central_impulse(total_pid)

		if total_error.length() > 100.0:
			drop_ball()
