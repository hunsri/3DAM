extends Node

var supported_asset_file_extensions = {
	"gltf": true,
	"glb": true,
	"obj": false,
	"fbx": false
}

func is_file_supported(filename: String) -> bool:
	return supported_asset_file_extensions.get(filename.get_extension(), false)
