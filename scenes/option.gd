extends Node
class_name Option

@onready var base = get_parent().get_parent()

@export var unselect_on_chosen : bool = true

func on_select():
	if unselect_on_chosen:
		Globals.player.obj_select.unselect()
