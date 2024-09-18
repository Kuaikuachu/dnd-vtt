extends TerrainObject
class_name TextureTerrain

func _ready():
	print(name)


func apply_mat(mat):
	if mat:
		self.get_child(0).get_child(0).mesh.material.albedo_texture = mat
		print(mat)
	
