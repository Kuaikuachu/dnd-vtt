extends Label3D
class_name ParentVarToText

@export var var_to_show : String

var pos_diff : Vector3

func _ready() -> void:
	pos_diff = position

func _physics_process(delta: float) -> void:
	global_position = get_parent().global_position + pos_diff
	if var_to_show:
		text = var_to_show + " = "
	if !var_to_show.is_empty():
		text += str(get_parent().get(var_to_show))
