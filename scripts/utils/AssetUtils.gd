class_name AssetUtils extends Node

const INFO_FILE_NAME: String = "asset_info.json"

static var supported_asset_file_extensions = {
	"gltf": true,
	"glb": true,
	"obj": false,
	"fbx": false
}

static func is_file_supported(filename: String) -> bool:
	return supported_asset_file_extensions.get(filename.get_extension(), false)

## Extracts all contents of the zip archive into an "Assets" directory in the same path
static func extract_assets_zip_archive(path: String, archive_name: String):
	_extract_all_from_zip(path+"/"+archive_name+".zip", path+"/Assets")

# Extract all files from a ZIP archive, preserving the directories within.
# This acts like the "Extract all" functionality from most archive managers.
static func _extract_all_from_zip(path_to_archive: String, path_to_destination: String):
	var reader = ZIPReader.new()
	reader.open(path_to_archive)
	
	# Ensure the destination directory exists.
	DirAccess.make_dir_recursive_absolute(path_to_destination)

	# Destination directory for the extracted files (this folder must exist before extraction).
	# Not all ZIP archives put everything in a single root folder,
	# which means several files/folders may be created in `root_dir` after extraction.
	var root_dir = DirAccess.open(path_to_destination)

	var files = reader.get_files()
	for file_path in files:
		# If the current entry is a directory.
		if file_path.ends_with("/"):
			root_dir.make_dir_recursive(file_path)
			continue

		# Write file contents, creating folders automatically when needed.
		# Not all ZIP archives are strictly ordered, so we need to do this in case
		# the file entry comes before the folder entry.
		root_dir.make_dir_recursive(root_dir.get_current_dir().path_join(file_path).get_base_dir())
		var file = FileAccess.open(root_dir.get_current_dir().path_join(file_path), FileAccess.WRITE)
		var buffer = reader.read_file(file_path)
		file.store_buffer(buffer)
		file.close()
