extends RigidBody2D

var _owner = null
var height : float = 0.0 

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

func _process(delta):
	$AnimatedSprite2D.play()
	if _owner:
		height = 20.0
		$AnimatedSprite2D.animation = "idle"
	else:
		height = 4.0
		$AnimatedSprite2D.animation = "moving"
	$Sprite2D.shadow_offset.x = lerp($Sprite2D.shadow_offset.x, height, delta * 2.0)
	$Sprite2D.shadow_offset.y = lerp($Sprite2D.shadow_offset.y, height, delta * 2.0)
	
