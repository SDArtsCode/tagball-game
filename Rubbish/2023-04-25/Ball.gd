extends RigidBody2D

var _owner = null

func _ready():
	pass # Replace with function body.

func set_col_enabled(enabled):
	$CollisionShape2D.disabled = !enabled

func set_in_hands(who : RigidBody2D):
	if who != null:
		_owner = self
		linear_damp = 4
	else:
		_owner = null
		linear_damp = 1
