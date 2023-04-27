extends RigidBody2D

var _owner = null
var height : float = 0.0 
var tween : Tween
func _ready():
	pass # Replace with function body.

func set_col_enabled(enabled):
	$CollisionShape2D.disabled = !enabled

func set_in_hands(who : RigidBody2D):
	if who != null:
		_owner = self
		linear_damp = 4
		$AnimationPlayer.play("bounce")
	else:
		_owner = null
		linear_damp = 1
		$AnimationPlayer.play("bounce")
		
func _process(delta):
	if _owner:
		height = 20.0
	else:
		height = 4.0
	$Sprite2D.shadow_offset.x = lerp($Sprite2D.shadow_offset.x, height, delta * 2.0)
	$Sprite2D.shadow_offset.y = lerp($Sprite2D.shadow_offset.y, height, delta * 2.0)
	
	if linear_velocity.length() > 10.0 and !_owner:
		$Sprite2D.rotation += delta * linear_velocity.length() / 30.0

func _on_music_queue_body_entered(body):
	if body.is_in_group("player") and MusicController.phase == 0:
		MusicController.play_intro()
