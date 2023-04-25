extends Sprite2D

class_name ShadowSprite2D

@export var shadow_offset : Vector2 = Vector2(20.0, 20.0)
@export_range(0.0, 1.0) var shadow_opacity : float = 0.5
var shadow : Sprite2D

func _ready():
	shadow = Sprite2D.new()
	add_child(shadow)
	if texture:
		shadow.texture = texture
	shadow.modulate = "000000"
	shadow.modulate.a = shadow_opacity
	shadow.z_index = -12
	
func _process(delta):
	if shadow.texture:
		shadow.global_position = global_position + shadow_offset
	else:
		if texture:
			shadow.texture = texture
