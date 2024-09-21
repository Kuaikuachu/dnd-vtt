extends Node3D

@export var size_modifier : float = 0.2

@onready var model: Node3D = $Model

@onready var collision_shape = get_child(self.get_child_count() - 1)

var random_speed : float = 2.0



	
func _ready():
	var rand_x = randf_range(-random_speed, random_speed)
	var rand_y = randf_range(-random_speed, random_speed)
	var rand_z = randf_range(-random_speed, random_speed)
	
	self.angular_velocity = Vector3(rand_x, rand_y, rand_z)
	
	
	model.scale = Vector3(size_modifier, size_modifier, size_modifier)
	collision_shape.scale = Vector3(size_modifier, size_modifier, size_modifier)
	
	print(collision_shape)
