extends TerrainObject
class_name TextureTerrain

func apply_mat(mat):
	if mat:
		self.get_child(0).get_child(0).get_active_material(0).albedo_texture = mat
	print(mat)
