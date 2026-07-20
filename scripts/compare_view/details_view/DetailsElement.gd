class_name DetailsElement extends Node

var tile: AssetTile2D

@export var asset_name_label: Label
@export var asset_spawn_root: Node3D

func setup(asset: AbstractAssetTile) -> void:
	if asset is AssetTile2D:
		tile = asset
	
	if tile == null:
		return
	
	asset_name_label.text = tile.asset_info.asset_file_name
	
	ModelLoader.load_attach_model(tile.asset_info.get_path_to_local_asset(), asset_spawn_root)
	
	print(tile.asset_info.get_path_to_local_asset())
	
	var scene = ModelLoader._load_model(tile.asset_info.get_path_to_local_asset())
	var info = analyze_glb(scene)
	
	print(info)
	
func _on_remove_pressed() -> void:
	queue_free()


### beware AI referenced CODE BELOW ###

func analyze_glb(scene: Node) -> Dictionary:
	var result = {
		"triangles": 0,
		"vertices": 0,
		"materials": [],
		"surfaces": 0
	}

	var material_set := {}

	_scan_node(scene, result, material_set)

	result.materials = material_set.values()
	return result


func _scan_node(node: Node, result: Dictionary, material_set: Dictionary):
	if node is MeshInstance3D:
		var mesh_instance: MeshInstance3D = node
		var mesh = mesh_instance.mesh

		if mesh:
			for surface in mesh.get_surface_count():
				result.surfaces += 1

				var arrays = mesh.surface_get_arrays(surface)
				var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
				var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]

				result.vertices += vertices.size()
				
				if indices.size() > 0:
					@warning_ignore("integer_division")
					result.triangles += indices.size() / 3
				else:
					@warning_ignore("integer_division")
					result.triangles += vertices.size() / 3

				var material = mesh.surface_get_material(surface)
				if material:
					material_set[material.resource_path] = material

	for child in node.get_children():
		_scan_node(child, result, material_set)
