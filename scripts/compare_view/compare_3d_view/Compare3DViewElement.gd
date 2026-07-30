class_name Compare3DViewElement extends Node3D

@onready var floor_plane: MeshInstance3D = $FloorPlane
@onready var asset_spawn_root: Node3D = $AssetSpawnRoot

const DIVIDER_SIZE: float = 0.1

func _ready() -> void:
	pass
	
func setup(model: Node3D, index: int = 0) -> void:
	
	# guard against out of bounds index 
	if index < 0 && index > get_parent().get_child_count():
		return
	
	asset_spawn_root.add_child(model)
	
	var model_AABB: Vector3 = AABB_Utils.get_world_aabb(model).size

	model.position.y = model_AABB.y / 2
	
	recalculate_grid_size(Vector2(model_AABB.x, model_AABB.z))
	
	_insert_into_list(index)

func display_as_shaded() -> void:
	MaterialUtils.remove_all_material_overrides(asset_spawn_root)

func display_as_wireframe() -> void:
	const WIREFRAME_SHADER = preload("uid://c18wb3rrwflb8")
	MaterialUtils.replace_all_material_overrides(asset_spawn_root, WIREFRAME_SHADER)

func display_as_uv() -> void:
	const UV_DISPLAY_SHADER = preload("res://shader_materials/uv_display.tres")
	MaterialUtils.replace_all_material_overrides(asset_spawn_root, UV_DISPLAY_SHADER)

func _insert_into_list(index: int) -> void:
	
	get_parent().move_child(self, index)
	
	_recalculate_position_following()

func _recalculate_position_following() -> void:
	
	var next_element: Compare3DViewElement = null
	
	# check if there even is a next element 
	if get_index() < get_parent().get_child_count()-1:
		next_element = get_parent().get_child(get_index()+1)
	 
	var previous_element: Compare3DViewElement = null
	
	if get_index() > 0:
		previous_element = get_parent().get_child(get_index()-1)
	
	if previous_element == null:
		position = Vector3(floor_plane.mesh.size.x/2, position.y, -floor_plane.mesh.size.y/2)
	else:
		position = Vector3(previous_element.position.x+previous_element.floor_plane.mesh.size.x/2+DIVIDER_SIZE+floor_plane.mesh.size.x/2, 0, -floor_plane.mesh.size.y/2)
		
	if next_element != null:
		next_element._recalculate_position_following()

func recalculate_grid_size(model_xz: Vector2) -> void:
	
	var mesh: Mesh = floor_plane.mesh.duplicate()
	var mat: ShaderMaterial = mesh.material.duplicate()
	
	var size = max(model_xz.x, model_xz.y)
	size = ceil(size)
	
	mat.set_shader_parameter("subdivisions", size)
	floor_plane.mesh = mesh
	floor_plane.mesh.size = Vector2(size, size)
	floor_plane.mesh.material = mat
