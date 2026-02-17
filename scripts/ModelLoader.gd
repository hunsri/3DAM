class_name ModelLoader

static var model_map: Dictionary[int, Node3D] = {}

static func load_attach_model(path_to_model: String, parent_node: Node3D) -> void:
	
	if not path_to_model.get_extension() in ["gltf", "glb"]:
		return
	
	# clearing the existing model from the previous view
	for child in parent_node.get_children():
		child.queue_free()
	
	# RessourceLoader only accepts from within res:// so we have to use our own loader
	var model: Node3D = _load_model(path_to_model)
	
	parent_node.add_child(model)

static func _load_model(path_to_model: String) -> Node3D:
	var model_hash: int = _model_hash(path_to_model)
	var model: Node3D = model_map.get(model_hash)
	
	if model == null:
		model = _load_from_disk(path_to_model)
		model_map.set(_model_hash(path_to_model), model)
	
	if model != null:
		return model.duplicate(true)
	return null

static func _load_from_disk(path_to_model: String) -> Node3D:
	var file_extension = path_to_model.get_extension()
	match file_extension:
		"gltf":
			return _load_gltf(path_to_model)
		"glb":
			return _load_gltf(path_to_model)
	
	return null
	
static func _model_hash(path_to_model: String) -> int:
	# uses path and last modified to calculate hash
	# ensures that modified versions aren't hitting same cache as old versions
	return (path_to_model+_read_last_modified(path_to_model)).hash()

static func _read_last_modified(file_path: String) -> String:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file == null:
		var last_modified = FileAccess.get_modified_time(file_path)  # Get last modified time
		file.close()
		return str(last_modified)
	else:
		print("Error opening the file:", file_path)

	return ""

static func _load_gltf(path_to_model: String) -> Node3D:
	var gltf := GLTFDocument.new()
	var gltf_state := GLTFState.new()
	var snd_file = FileAccess.open(path_to_model, FileAccess.READ)
	if snd_file == null:
		push_error("Failed to read model %s" % [path_to_model])
		return null
		
	var fileBytes = PackedByteArray()
	fileBytes = snd_file.get_buffer(snd_file.get_length())
	gltf.append_from_buffer(fileBytes, path_to_model, gltf_state, 8)
	return gltf.generate_scene(gltf_state)
