extends Node2D

@onready var obj_name: Label = %obj_name

@export var menu_button : PackedScene

@onready var buttons_parent: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer

var selected_object

func unselect():
	visible = false
	obj_name.text = "NOTHING SELECTED"

func select(obj):
	position = get_viewport().get_mouse_position()
	for i in buttons_parent.get_children():
		if i is Button:
			i.queue_free()
	obj_name.text = str(obj.real_name)

	for i in obj.menu_options.get_children():
		add_option(i)
	visible = true

func add_option(option):
	var new_button = menu_button.instantiate()
	new_button.text = option.name
	new_button.option_node = option
	buttons_parent.add_child(new_button)
