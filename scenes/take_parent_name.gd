@tool
extends Label3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text = str(get_parent().name)
	global_position = get_parent().global_position

func _process(delta: float) -> void:
	text = str(get_parent().name)
	global_position = get_parent().global_position
