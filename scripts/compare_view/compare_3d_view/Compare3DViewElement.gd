class_name Compare3DViewElement extends Node3D

var floor_plane: MeshInstance3D

@onready var floor_plane_fallback: MeshInstance3D = $FloorPlaneFallback
@onready var asset_spawn_root: Node3D = $AssetSpawnRoot

const DIVIDER_SIZE: float = 0.1

func _ready() -> void:
	floor_plane = floor_plane_fallback.duplicate()
	
func setup(model: Node3D, index: int = 0, p_floor_plane: MeshInstance3D = null) -> void:
	
	# guard against out of bounds index 
	if index < 0 && index > get_parent().get_child_count():
		return
	
	if p_floor_plane != null:
		floor_plane = p_floor_plane
		floor_plane.visible = true
	
	asset_spawn_root.add_child(model)
	
	var model_AABB: Vector3 = AABB_Utils.get_world_aabb(model).size

	model.position.y = model_AABB.y / 2
	
	floor_plane.position = Vector3(0, 0, 0)
	self.add_child(floor_plane)
		
	recalculate_grid_size(Vector2(model_AABB.x, model_AABB.z))
		
	_insert_into_list(index)

func display_as_shaded() -> void:
	MaterialUtils.remove_all_material_overrides(asset_spawn_root)

func display_as_unshaded() -> void:
	MaterialUtils.override_all_material_unshaded(asset_spawn_root)

func display_as_wireframe() -> void:
	const WIREFRAME_SHADER = preload("uid://c18wb3rrwflb8")
	MaterialUtils.replace_all_material_overrides(asset_spawn_root, WIREFRAME_SHADER)

func display_as_uv() -> void:
	const UV_DISPLAY_SHADER = preload("res://shader_materials/uv_display.tres")
	MaterialUtils.replace_all_material_overrides(asset_spawn_root, UV_DISPLAY_SHADER)

func _insert_into_list(index: int) -> void:
	
	get_parent().move_child(self, index)
	
	_calculate_insertion_position()
	
	if has_next_sibling():
		_offset_beginning_from(get_next_sibling(), self.floor_plane.mesh.size.x + DIVIDER_SIZE)


func remove() -> void:
	
	if has_next_sibling():
		_offset_beginning_from(get_next_sibling(), -self.floor_plane.mesh.size.x - DIVIDER_SIZE)
	
	self.queue_free()

func _calculate_insertion_position(offset: Vector3 = Vector3(0, 0, 0)) -> void:
	
	var previous_element: Compare3DViewElement
	
	if get_index() == 0:
		previous_element = null
	else:
		previous_element = get_parent().get_child(get_index()-1)
	
	if previous_element == null:
		position = Vector3(floor_plane.mesh.size.x/2, position.y, -floor_plane.mesh.size.y/2) + offset
	else:
		position = Vector3(previous_element.position.x+previous_element.floor_plane.mesh.size.x/2+DIVIDER_SIZE+floor_plane.mesh.size.x/2, 0, -floor_plane.mesh.size.y/2) + offset
		

func _offset_beginning_from(first_sibling_to_offset: Compare3DViewElement, offset_x: float) -> void:
	
	if first_sibling_to_offset == null:
		return
	
	first_sibling_to_offset.position.x = first_sibling_to_offset.position.x + offset_x
	
	_offset_beginning_from(first_sibling_to_offset.get_next_sibling(), offset_x)

## Returns whether there exists a sibling with a higher index
func has_next_sibling() -> bool:
	if get_parent().get_child_count()-1 == get_index():
		return false
	else:
		return true
		
func get_next_sibling() -> Compare3DViewElement:
	if self.has_next_sibling():
		return get_parent().get_child(get_index()+1)
	else:
		return null

func recalculate_grid_size(model_xz: Vector2) -> void:
	
	var mesh: Mesh = floor_plane.mesh.duplicate()
	var mat: ShaderMaterial = mesh.material.duplicate()
	
	var size = max(model_xz.x, model_xz.y)
	size = ceil(size)
	
	mat.set_shader_parameter("subdivisions", size)
	floor_plane.mesh = mesh
	floor_plane.mesh.size = Vector2(size, size)
	floor_plane.mesh.material = mat
