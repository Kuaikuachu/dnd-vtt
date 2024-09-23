extends Node3D

@export var size_modifier : float = 0.2

@onready var model: Node3D = $Model

@onready var collision_shape = get_child(self.get_child_count() - 1)

var random_speed : float = 5.0

@onready var sides: Node3D = $Sides



	
func _ready():
	var rand_x = randf_range(-random_speed, random_speed)
	var rand_y = randf_range(-random_speed, random_speed)
	var rand_z = randf_range(-random_speed, random_speed)
	
	self.angular_velocity = Vector3(rand_x, rand_y, rand_z)
	
	
	model.scale = Vector3(size_modifier, size_modifier, size_modifier)
	collision_shape.scale = Vector3(size_modifier, size_modifier, size_modifier)
	
	print(collision_shape)


func _physics_process(delta: float) -> void:
	if self.angular_velocity.length() + self.linear_velocity.length() < 0.3:
		print(calc_up_side())


func calc_up_side():
	var highest_marker : Marker3D 
	for i in sides.get_children():
		if !highest_marker:
			highest_marker = i
		elif highest_marker.global_position.y < i.global_position.y:
			highest_marker = i
	return highest_marker.name
