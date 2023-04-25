extends RigidBody2D

@export var id := 0
const MOVE_DEADZONE := 0.2
const TURN_DEADZONE := 0.2

const MAX_SPEED = 200.0
const ACCEL = 7.0

var vel := Vector2.ZERO
var turn := Vector2.ZERO
var can_slide : bool = true
var sliding : bool = false
const SLIDE_RESET_TIME : float = 3.0
var ball_in_area : RigidBody2D = null
var ball : RigidBody2D = null

var kp : float = 1.0
var ki : float = 0.05
var kd : float = 1.1
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

func drop_ball(force : Vector2 = Vector2()):
	if force != Vector2():
		ball.apply_central_impulse(force)
	reset_pid()
	ball.set_in_hands(null)
	ball = null
	$HasBallNoti.visible = false
	
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

	if !can_slide:
		$UI/SlideBar.value = 100 - int(100 * ($Timer.time_left / SLIDE_RESET_TIME))
	if Input.is_action_just_pressed("slide") and can_slide and linear_velocity.length() > 50.0:
		sliding = true
		linear_velocity *= 2.8
		$UI/SlideBar.value = 0
		
	if Input.is_action_just_released("slide") and sliding:
		sliding = false
		can_slide = false
		$Timer.start(SLIDE_RESET_TIME)
		
	if Input.is_action_pressed("slide") and sliding:
		linear_velocity.x = lerp(linear_velocity.x, 0.0, state.step * 0.6)
		linear_velocity.y = lerp(linear_velocity.y, 0.0, state.step * 0.6)
	else:
		if linear_velocity.length() > 50.0:
			$AnimationPlayer.play("walking")
		else:
			$AnimationPlayer.play("idle")

		if dir.length() > 1.0:
			linear_velocity = lerp(linear_velocity, dir.normalized()*MAX_SPEED, state.step*ACCEL)
		else:
			linear_velocity = lerp(linear_velocity, dir*MAX_SPEED, state.step*ACCEL)
		if dir.length() > TURN_DEADZONE:
			$Rotate.rotation = lerp_angle($Rotate.rotation, atan2(dir.y, dir.x) - PI/2, state.step*8.0)
		
	ball_in_area = null
	for child in $Rotate/RayCasts.get_children():
		if child.is_colliding():
			if child.get_collider().is_in_group('ball'):
				ball_in_area = child.get_collider()
				break
	if Input.is_action_just_pressed("pickup"):
		if ball: # drop ball
			drop_ball()
		elif ball_in_area:
			ball = ball_in_area
			ball.set_in_hands(self)
			$HasBallNoti.visible = true
			set_collision_mask_value(2, false)
			set_collision_layer_value(2, false)
			
	if ball != null:
		var total_error = ($Rotate/BallMarker.global_position - ball.global_position)
		var total_pid = Vector2()
		b_error = total_error.x
		if abs(b_error) > 10.0:
			var pid_p = b_error * kp
			var pid_d = kd * (b_error-b_prev_error)/state.step
			var pid_pd = pid_p + pid_d
			b_pid_i += b_error * ki * state.step
			var pid = pid_pd + b_pid_i
			total_pid.x = pid
		else:
			b_pid_i = 0.0
		b_prev_error = b_error
		# R
		r_error = total_error.y
		if abs(r_error) > 10.0:
			var pid_p = r_error * kp
			var pid_d = kd * (r_error-r_prev_error)/state.step
			var pid_pd = pid_p + pid_d
			r_pid_i += r_error * ki * state.step
			var pid = pid_pd + r_pid_i
			total_pid.y = pid
		else:
			b_pid_i = 0.0
		r_prev_error = r_error
		ball.apply_central_impulse(total_pid)
		$HasBallNoti.rotation += state.step * 0.5 * PI * 2
		
		if total_error.length() > 70.0:
			drop_ball()
		if Input.is_action_just_pressed("throw"):
			drop_ball(Vector2(cos($Rotate.rotation + PI/2), sin($Rotate.rotation + PI/2)) * 700.0)
			
func _on_timer_timeout():
	can_slide = true

func _on_ball_exit_area_body_exited(body):
	if ball == null and body.is_in_group('ball'):
		set_collision_mask_value(2, true)
		set_collision_layer_value(2, true)
