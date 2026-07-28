class_name Compare3DViewElement extends Node

@onready var floor_plane: MeshInstance3D = $FloorPlane
@onready var target: Node3D = $Target

#const DEBUG = preload("uid://1tdgxj7idny")

func _ready() -> void:
	pass
	#var deb = DEBUG.instantiate()
	#
	#setup(deb)
	
func setup(model: Node3D) -> void:
		
	target.add_child(model)
	
	var model_AABB: Vector3 = AABB_Utils.get_world_aabb(model).size

	model.position.y = model_AABB.y / 2
	
	recalculate_grid_size(Vector2(model_AABB.x, model_AABB.z))

func recalculate_grid_size(model_xz: Vector2) -> void:
	
	var mat: ShaderMaterial = floor_plane.mesh.material
	
	var size = max(model_xz.x, model_xz.y)
	size = ceil(size)
	
	mat.set_shader_parameter("subdivisions", size)
	floor_plane.mesh.size = Vector2(size, size)
