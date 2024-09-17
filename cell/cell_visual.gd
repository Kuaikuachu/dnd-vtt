extends Node3D

@export var grid_size = 100

@onready var model: Node3D = $Model
var mesh
var shader

var manipulator_x_uv : float = 0.5
var manipulator_y_uv : float = 0.5


func _ready() -> void:
	mesh = model.get_child(0).mesh
	shader = mesh.material

func _set_manipulator_pos(x : float = 1000, y : float = 1000):
	var x_uv
	var y_uv
	
	x_uv = (grid_size / 2 + x) / grid_size
	y_uv = (grid_size / 2 + y) / grid_size
	
	shader.set_shader_parameter("cell_manipulator_uv_pos", Vector2(x_uv, y_uv))
	
