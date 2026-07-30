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
