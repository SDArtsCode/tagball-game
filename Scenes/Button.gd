extends Node2D


var init_button_y
@export var connected_door_path : NodePath = ""
var connected_door = null
func _ready():
	connected_door = get_node(connected_door_path)
	init_button_y = $RigidBody2D.position.y

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var rot_mult = Vector2(cos(rotation + PI/2), sin(rotation + PI/2))
	if $RigidBody2D.position.y > $GrooveJoint2D.length + init_button_y - 6: # buffer zone
		if connected_door: 
			connected_door.active = true
	else:
		if connected_door: 
			connected_door.active = false
	$RigidBody2D.apply_central_impulse(-4.0 * rot_mult)
