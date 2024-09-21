extends FigureObject
class_name TextureToken


@onready var token: Node3D = $Token


func apply_mat(mat):
	if mat:
		self.get_child(0).get_child(0).get_active_material(0).albedo_texture = mat
