class_name AssetInfoHandler extends Node

@onready var spawn_point: Node3D = %SpawnPoint
@onready var spring_arm_3d: SpringArm3D = %SpringArm3D


func load_model(path_to_model: String):
	
	reset_model()
	var file_extension = path_to_model.get_extension()
	
	match file_extension:
		"gltf":
			spawn_point.add_child(_load_gltf(path_to_model))
		"glb":
			spawn_point.add_child(_load_gltf(path_to_model))

func _load_gltf(path_to_model: String) -> Node3D:
	var gltf := GLTFDocument.new()
	var gltf_state := GLTFState.new()
	var snd_file = FileAccess.open(path_to_model, FileAccess.READ)
	var fileBytes = PackedByteArray()
	fileBytes = snd_file.get_buffer(snd_file.get_length())
	gltf.append_from_buffer(fileBytes, path_to_model, gltf_state, 8)
	return gltf.generate_scene(gltf_state)

func reset_model():
	for child in spawn_point.get_children():
		child.queue_free()
	
	spawn_point.rotation = Vector3(0,0,0)
	spring_arm_3d.spring_length = 3 #arbitrary distance for now
