class_name MaterialUtils extends Node

static func replace_all_material_overrides(root: Node, new_material: Material) -> void:
	for child in root.get_children():
		if child is MeshInstance3D:
			child.material_override = new_material
		replace_all_material_overrides(child, new_material)

static func remove_all_material_overrides(root: Node) -> void:
	for child in root.get_children():
		if child is MeshInstance3D:
			child.material_override = null
		remove_all_material_overrides(child)

static func override_all_material_unshaded(root: Node) -> void:
	for child in root.get_children():
		if child is MeshInstance3D:
			var mat = child.mesh.surface_get_material(0).duplicate()
			mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			#child.set_surface_override_material(0, mat)
			child.material_override = mat
		override_all_material_unshaded(child)
