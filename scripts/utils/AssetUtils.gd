class_name AssetUtils extends Node

const ASSET_INFO_FILE_NAME: String = "asset_info.json"
const ASSET_ZIP_FILE_NAME: String = "assets.zip"
const ASSET_DIR_NAME: String = "assets"

static var supported_asset_file_extensions = {
	"gltf": true,
	"glb": true,
	"obj": false,
	"fbx": false
}

# a very basic check that should improved later on
static func is_file_3D_model(file_path: String) -> bool:
	
	# in case path leads to a directory
	var dir := DirAccess.open(file_path)
	if dir != null:
		return false
	
	var file_name = file_path.get_file()
	if supported_asset_file_extensions.has(file_name.get_extension()):
		return true
	
	return false

static func is_file_name_supported(filename: String) -> bool:
	return supported_asset_file_extensions.get(filename.get_extension(), false)

## Creates an asset info file into the given asset directory
## [param target_path] - usually the directory of the package version
## Returns bool - true on success
static func create_asset_info_file(asset_info: AssetInfo, target_path: String) -> bool:
	var asset_info_path = target_path +"/"+ ASSET_INFO_FILE_NAME
	var file := FileAccess.open(asset_info_path, FileAccess.WRITE)
	
	if file == null:
		push_error("Failed to open file for writing: %s" % [asset_info_path])
		return false
	
	file.store_string(asset_info.to_json_string())
	file.close()
	return true

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

## Inserts the given archive into the provided version [br]
## By default inserts and unpacks the archive and deletes it afterwards
static func place_asset_zip(version_path: String, zip_archive_data: PackedByteArray, unpack: bool = true, keep_zip: bool = false) -> bool:
	var target_directory := version_path
	if target_directory == "":
		return false
	
	var zip_path := target_directory+"/"+ASSET_ZIP_FILE_NAME
	
	var file = FileAccess.open(zip_path, FileAccess.WRITE)
	if file == null:
		return false
	
	for i in zip_archive_data.size():
		file.store_8(zip_archive_data.get(i))
	
	file.close()
	
	if unpack:
		ZipUtils.extract_all_from_zip(zip_path, target_directory+"/"+ASSET_DIR_NAME)
	
	if not keep_zip:
		var dir = DirAccess.open(target_directory)
		dir.remove(zip_path)
	
	return true
