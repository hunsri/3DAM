extends Object
class_name ZipUtils
## A class to helps handling zip archives
##
## The provided functions are intended for compressing and decompressing assets
## in the preparation of the exchange of data with asset-servers

const TEMP_ZIP_DIR = "user://temp/upload_cache"
const STANDARD_ARCHIVE_NAME: String = "assets.zip"

# Read a single file from a ZIP archive.
static func read_zip_file(path_to_archive: String, path_in_archive:String):
	var reader = ZIPReader.new()
	var err = reader.open(path_to_archive)
	if err != OK:
		return PackedByteArray()
	var res = reader.read_file(path_in_archive)
	reader.close()
	return res

# Extract all files from a ZIP archive, preserving the directories within.
static func extract_all_from_zip(path_to_archive: String, path_to_destination: String):
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

## Creates a zip-archive of a given asset to be used to upload it to an asset-server [br]
## The zip-archive is placed under [constant ZipUtils.TEMP_ZIP_DIR] [br]
## 
## If asset is part of a package, the asset_info of the respective package_version must be provided
## Returns the path to the created zip-archive
static func create_zip_from_asset_info(asset_info: AssetInfo) -> String:
	var target = asset_info.get_path_to_local_asset()
	
	#TODO delete cache entry after upload
	
	# This could create a potential collision if we aren't careful, best to delete the cache after upload
	var destination = TEMP_ZIP_DIR +"/"+ asset_info.package_name
	return create_zip_archive(target, destination, asset_info)

## Creates a zip archive [br]
## Created archive will always be of the name [constant ZipUtils.STANDARD_ARCHIVE_NAME] [br]
## Returns the path to the created archive
static func create_zip_archive(path_to_target: String, path_to_destination: String, asset_info: AssetInfo) -> String:
	var zipper := ZIPPacker.new()
	var zip_path := path_to_destination +"/"+ STANDARD_ARCHIVE_NAME
	
	_create_path(path_to_destination)
	var err = zipper.open(zip_path)
	if err != OK:
		push_error("Failed to create a zip archive")
	
	_add_file(zipper, path_to_target)
	
	var global_paths := asset_info.get_path_to_local_dependencies_globalized()
	var relative_paths := asset_info.get_path_to_local_dependencies_relative()
	
	for i in asset_info.get_path_to_local_dependencies_relative().size():
		_add_file(
			zipper,
			global_paths[i],
			relative_paths[i]
		)
	
	zipper.close()
	return ProjectSettings.globalize_path(zip_path)

static func _add_file(zipper: ZIPPacker, source_file_path: String, target_path_in_zip: String = ""):
	if target_path_in_zip == "":
		target_path_in_zip = source_file_path.get_file()
	
	zipper.start_file(target_path_in_zip)
	zipper.write_file(_get_packed_bytes(source_file_path))
	zipper.close_file()

static func _add_dir_recursive(zipper: ZIPPacker, root: String, current: String) -> void:
	var dir := DirAccess.open(current)
	if dir == null:
		return

	for name in dir.get_files():
		var full_path := current.path_join(name)
		var relative_path := full_path.trim_prefix(root + "/")

		var file := FileAccess.open(full_path, FileAccess.READ)
		if file:
			zipper.start_file(relative_path)
			zipper.write_file(file.get_buffer(file.get_length()))
			zipper.close_file()

	for subdir in dir.get_directories():
		_add_dir_recursive(zipper, root, current.path_join(subdir))

static func _get_packed_bytes(path: String) -> PackedByteArray:
	var fa := FileAccess.open(path, FileAccess.READ)
	if fa == null:
		push_error("Failed to open: %s" % path)
		return PackedByteArray()
	var bytes := fa.get_buffer(fa.get_length()) as PackedByteArray
	fa.close()
	return bytes

static func _create_path(file_path: String) -> bool:
	var dir_path := ProjectSettings.globalize_path(file_path)
	var root := DirAccess.open("")  # required to call make_dir_recursive
	if root == null:
		return false
	var err := root.make_dir_recursive(dir_path)
	return err == OK
