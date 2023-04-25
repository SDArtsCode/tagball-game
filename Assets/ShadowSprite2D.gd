extends Sprite2D

class_name ShadowSprite2D

@export var shadow_offset : Vector2 = Vector2(20.0, 20.0)
@export var shadow_parent_path : NodePath
@export_range(0.0, 1.0) var shadow_opacity : float = 0.5
var shadow : Sprite2D

func _ready():
	shadow = Sprite2D.new()
	if !is_instance_valid(get_node(shadow_parent_path)):
		add_child(shadow)
	else:
		get_node(shadow_parent_path).add_child(shadow)
	if texture:
		shadow.texture = texture
	shadow.modulate = "000000"
	shadow.modulate.a = shadow_opacity
	shadow.z_index = -12
	
func _process(delta):
	if shadow.texture:
		if !is_instance_valid(get_node(shadow_parent_path)):
			shadow.global_position = global_position + shadow_offset
		else:
			shadow.rotation = self.rotation
			shadow.position = self.position + Vector2(get_node(shadow_parent_path).size / 2) + shadow_offset
	else:
		if texture:
			shadow.texture = texture
