class_name DetailsElement extends Node

const DETAILS_ELEMENT_ENTRY_ITEM = preload("uid://jwxjevp5g6qc")

var tile: AssetTile2D

@export var asset_name_label: Label
@export var asset_spawn_root: Node3D

@export var details_elements_root: VBoxContainer

func setup(asset: AbstractAssetTile) -> void:
	if asset is AssetTile2D:
		tile = asset
	
	if tile == null:
		return
	
	asset_name_label.text = tile.asset_info.asset_file_name
	
	ModelLoader.load_attach_model(tile.asset_info.get_path_to_local_asset(), asset_spawn_root)
	
	var scene = ModelLoader._load_model(tile.asset_info.get_path_to_local_asset())
	var info = analyze_glb(scene)
	
	populate_details_items(info)
	
func _on_remove_pressed() -> void:
	queue_free()

func populate_details_items(info: Dictionary) -> void:

	for key in info:
		var item: DetailsElementEntryItem = DETAILS_ELEMENT_ENTRY_ITEM.instantiate()
		
		var value = info[key]

		if typeof(value) == TYPE_ARRAY:
			value = str(value.size())
		else:
			value = str(info[key])
		
		item.setup(key, value)
		details_elements_root.add_child(item)

func display_as_shaded() -> void:
	remove_all_material_overrides(asset_spawn_root)

func display_as_wireframe() -> void:
	const WIREFRAME_SHADER = preload("uid://c18wb3rrwflb8")
	replace_all_material_overrides(asset_spawn_root, WIREFRAME_SHADER)

func display_as_uv() -> void:
	const UV_DISPLAY_SHADER = preload("res://shader_materials/uv_display.tres")
	replace_all_material_overrides(asset_spawn_root, UV_DISPLAY_SHADER)

### beware AI referenced CODE BELOW ###
# seems alright after necessary adjustments, but if you find a bug you know the drill
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


func replace_all_material_overrides(root: Node, new_material: Material) -> void:
	for child in root.get_children():
		if child is MeshInstance3D:
			child.material_override = new_material
		replace_all_material_overrides(child, new_material)

func remove_all_material_overrides(root: Node) -> void:
	for child in root.get_children():
		if child is MeshInstance3D:
			child.material_override = null
		remove_all_material_overrides(child)
