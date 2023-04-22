extends Node


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
func _process(_delta):
	if Input.is_action_just_pressed("quick_exit"):
		get_tree().quit()
	if Input.is_action_just_pressed("quick_restart"):
		get_tree().reload_current_scene()
