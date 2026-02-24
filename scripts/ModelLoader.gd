class_name ModelLoader

## structure for keeping loaded models in memory to avoid another reload from disk
## each Node3D gets a hash key assigned
static var model_map: Dictionary[int, Node3D] = {}

static func load_attach_model(path_to_model: String, parent_node: Node3D) -> void:
	
	if not AssetUtils.is_file_3D_model(path_to_model):
		return
	
	if not AssetUtils.is_file_name_supported(path_to_model.get_file()):
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
	var file = FileAccess.open(path_to_model, FileAccess.READ)
	if file == null:
		push_error("Failed to read model %s" % [path_to_model])
		return null
		
	var fileBytes = PackedByteArray()
	fileBytes = file.get_buffer(file.get_length())
	gltf.append_from_buffer(fileBytes, path_to_model, gltf_state, 8)
	
	return gltf.generate_scene(gltf_state)

static func get_dependencies(path_to_model: String) -> Array[String]:
	var file_type = path_to_model.get_extension()
	var dependencies: Array[String] = []
	
	match file_type.to_lower():
		"gltf":
			dependencies = get_gltf_dependencies(path_to_model)
	
	return dependencies

static func get_gltf_dependencies(path_to_model: String) -> Array[String]:
	var file = FileAccess.open(path_to_model, FileAccess.READ)
	if file == null:
		push_error("Failed to read model %s" % [path_to_model])
		return []
	
	var gltf_json_string = file.get_as_text()
	var json = JSON.parse_string(gltf_json_string)
	if json == null:
		return []
	
	var ret: Array[String] = []
	
	var buffer_deps: Array = json.get("buffers", "")
	if buffer_deps != []:
		for dep in buffer_deps:
			ret.append(dep.get("uri", ""))
			
	var image_deps: Array = json.get("images", "")
	if image_deps != []:
		for dep in image_deps:
			ret.append(dep.get("uri", ""))
	
	return ret
