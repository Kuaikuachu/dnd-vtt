extends Button

var option_node : Node

func _on_button_up() -> void:
	if option_node:
		option_node.on_select()
