extends RigidBody2D

@export var id := 0

const MOVE_DEADZONE := 0.2 #ignore
const TURN_DEADZONE := 0.2 #ignore
const MAX_SPEED = 200.0 # walking
const ACCEL = 7.0 # walking accel
const SLIDE_RESET_TIME : float = 2.0 # how much time until can slide again
const SLIDE_SPEED_MULT : float = 3.7 # when pressing slide, how much is the current vel multipled by
const SCORE_PER_TIME : float = 0.5 # 1 score is given in this amount of time (seconds)
const THROW_FORCE : float = 800.0 

var vel := Vector2.ZERO
var turn := Vector2.ZERO
var can_slide : bool = true
var sliding : bool = false
var ball_in_area : RigidBody2D = null
var ball : RigidBody2D = null
var score_time : float = 0.0
var score : int = 0 

# PID constants
var kp : float = 1.0
var ki : float = 0.05
var kd : float = 1.1
# ignore extra PID variables
var b_error : float = 0.0
var b_prev_error : float = 0.0
var b_pid_i : float = 0.0
var r_error : float = 0.0
var r_prev_error : float = 0.0
var r_pid_i : float = 0.0

@export_color_no_alpha var green_color : Color
@export_color_no_alpha var pink_color : Color
@export_color_no_alpha var green_color_alt : Color
@export_color_no_alpha var pink_color_alt : Color

@export_range(0, 1) var team : int = 0
signal max_ball_time_reached(team_num)

var locked : bool = false
var id_colors = [Color("FF0000"), Color("00D1FF"), Color("14FF00"), Color("FFC700")]
var wall_particles = preload("res://Scenes/WallParticles.tscn")

func set_locked(yes : bool):
	locked = yes
		
func _ready():
	$UI/Noti.modulate = id_colors[id]
	if team == 0: # color feet, arms, torso
		# green
		$Rotate/GreenPlayerShoeRight.modulate = green_color_alt
		$Rotate/GreenPlayerShoeLeft.modulate = green_color_alt
		$Rotate/ShoulderLeft/Arm.modulate = green_color
		$Rotate/ShoulderRight/Arm.modulate = green_color
		$Rotate/TestPlayer.modulate = green_color
		pass
	elif team == 1:
		# pink
		$Rotate/GreenPlayerShoeRight.modulate = pink_color_alt
		$Rotate/GreenPlayerShoeLeft.modulate = pink_color_alt
		$Rotate/ShoulderLeft/Arm.modulate = pink_color
		$Rotate/ShoulderRight/Arm.modulate = pink_color
		$Rotate/TestPlayer.modulate = pink_color
	elif team == 2:
		pass
	else:
		pass
	
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
	# music stuff
	# /music
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
		
	if Input.is_joy_button_pressed(id, JOY_BUTTON_RIGHT_SHOULDER) and sliding:
		$AnimationPlayer.play("sliding")
		$MoveParticles.emitting = false
		print("YES")
		linear_velocity.x = lerp(linear_velocity.x, 0.0, state.step * 0.6)
		linear_velocity.y = lerp(linear_velocity.y, 0.0, state.step * 0.6)
	else:
		if linear_velocity.length() > 50.0:
			$MoveParticles.emitting = true
			$AnimationPlayer.play("walking")
		else:
			$MoveParticles.emitting = false
			$AnimationPlayer.play("idle")

		if dir.length() > 1.0:
			linear_velocity = lerp(linear_velocity, dir.normalized()*MAX_SPEED, state.step*ACCEL)
		else:
			linear_velocity = lerp(linear_velocity, dir*MAX_SPEED, state.step*ACCEL)
		if dir.length() > TURN_DEADZONE:
			$Rotate.rotation = lerp_angle($Rotate.rotation, atan2(dir.y, dir.x) - PI/2, state.step*8.0)
	
	if ball != null:
		if score < 100:
			score_time += state.step
			if score_time >= SCORE_PER_TIME:
				score_time = 0.0
				score += 1
				$UI/ScoreBar.value = score
				$UI/Label.text = str(score) + "/100"
			if score >= 100:
				emit_signal("max_ball_time_reached", self)
				print("PLAYER WINS")
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
		#$Rotate/ShoulderLeft.visible = true
		#$Rotate/ShoulderRight.visible = true
		var left_error = (ball.global_position + Vector2(-25.0, 0.0).rotated($Rotate.rotation) - $Rotate/ShoulderLeft.global_position)
		$Rotate/ShoulderLeft.global_rotation = atan2(left_error.y, left_error.x) - PI
		var right_error = (ball.global_position + Vector2(25.0, 0.0).rotated($Rotate.rotation) - $Rotate/ShoulderRight.global_position)
		$Rotate/ShoulderRight.global_rotation = atan2(right_error.y, right_error.x)
		
		if total_error.length() > 70.0:
			drop_ball()
	else:
		score_time = 0.0
		#$Rotate/ShoulderLeft.visible = false
		#$Rotate/ShoulderRight.visible = false
		if sliding:
			$Rotate/ShoulderRight.rotation = lerp_angle($Rotate/ShoulderRight.rotation, -PI/3, state.step * 8.0)
			$Rotate/ShoulderLeft.rotation = lerp_angle($Rotate/ShoulderLeft.rotation, PI/3, state.step * 8.0)
		else:
			$Rotate/ShoulderRight.rotation = lerp_angle($Rotate/ShoulderRight.rotation, PI/2.5, state.step * 3.0)
			$Rotate/ShoulderLeft.rotation = lerp_angle($Rotate/ShoulderLeft.rotation, -PI/2.5, state.step * 3.0)
	if locked:
		linear_velocity = Vector2()
		
func _on_timer_timeout():
	can_slide = true

func _on_ball_exit_area_body_exited(body):
	if ball == null and body.is_in_group('ball'):
		set_collision_mask_value(2, true)
		set_collision_layer_value(2, true)

func _input(event):
	if event.device != id and !locked:
		return
	if ball and event.is_action_pressed("throw"):
			drop_ball(Vector2(cos($Rotate.rotation + PI/2), sin($Rotate.rotation + PI/2)) * THROW_FORCE)

	if event.is_action_pressed("pickup"):
		ball_in_area = null
		for child in $Rotate/RayCasts.get_children():
			if child.is_colliding():
				if child.get_collider().is_in_group('ball'):
					ball_in_area = child.get_collider()
					break
		if ball: # drop ball
			MusicController.drop()
			drop_ball()
		elif ball_in_area:
			ball = ball_in_area
			ball.set_in_hands(self)
			$AnimationPlayer3.play("bounce")
			$HasBallNoti.visible = true
			set_collision_mask_value(2, false)
			set_collision_layer_value(2, false)
			if Global.first_time: Global.first_time = false
			elif Global.last_picked != team:
				Global.last_picked = team
				MusicController.switch_team()
				
			elif Global.last_picked == team:
				MusicController.phase = MusicController.mem
			
	if event.is_action_pressed("slide") and can_slide and linear_velocity.length() > 50.0:
		$SlideParticles.restart()
		$SlideParticles.emitting = true
		sliding = true
		linear_velocity *= SLIDE_SPEED_MULT
		$UI/SlideBar.value = 0
	if event.is_action_released("slide") and sliding:
		sliding = false
		can_slide = false
		$Timer.start(SLIDE_RESET_TIME)
	if event.is_action_pressed("noti"):
		$UI/Noti.show()
		$AnimationPlayer4.play("bounce")
	elif event.is_action_released("noti"):
		$UI/Noti.hide()
	
	if event.is_action_pressed("debug") and id == 0:
		team = 0

func _on_body_entered(body):
	$AnimationPlayer2.play("bounce")
	#$WallParticles.restart()
	#$WallParticles.emitting = true

