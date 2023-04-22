extends Node2D
class_name Door2D

var active := false
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if active: 
		$RigidBody2D.apply_central_impulse(Vector2(0.0, -20.0))
	else:
		$RigidBody2D.apply_central_impulse(Vector2(0.0, 20.0))
func activate():
	pass
	
func deactivate():
	pass
