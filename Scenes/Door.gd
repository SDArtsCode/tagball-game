extends Node2D
class_name Door2D

var active := false
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var rot_mult = Vector2(cos(rotation + PI/2), sin(rotation + PI/2))
	if active: 
		$RigidBody2D.apply_central_impulse(-20.0 * rot_mult)
	else:
		$RigidBody2D.apply_central_impulse(20.0 * rot_mult)
func activate():
	pass
	
func deactivate():
	pass
