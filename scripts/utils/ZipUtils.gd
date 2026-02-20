extends Object
class_name ZipUtils

static var TEMP_ZIP_DIR = "user://temp/upload_cache"
static var STANDARD_ARCHIVE_NAME: String = "assets.zip"

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
# This acts like the "Extract all" functionality from most archive managers.
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

static func create_zip_from_asset_info(currently_open_directory: String, asset_info: AssetInfo) -> String:
	var target := ProjectSettings.globalize_path(currently_open_directory +"/"+ asset_info.asset_file_name)
	
	#TODO check if target is a package
	#TODO check for asset dependencies
	
	# This could create a potential collision if we aren't careful, best to delete the cache after upload
	var destination = TEMP_ZIP_DIR +"/"+ asset_info.package_name
	return create_zip_archive(target, destination)

static func create_zip_archive(path_to_target: String, path_to_destination: String) -> String:
	var zipper := ZIPPacker.new()
	var zip_path := path_to_destination +"/"+ STANDARD_ARCHIVE_NAME
	
	_create_path(path_to_destination)
	var err = zipper.open(zip_path)
	if err != OK:
		push_error("Failed to create a zip archive")
	
	_add_file(zipper, path_to_target)
	
	zipper.close()
	return ProjectSettings.globalize_path(zip_path)

static func _add_file(zipper: ZIPPacker, file_path: String):
	var relative_path = file_path.get_file()
	
	zipper.start_file(relative_path)
	zipper.write_file(_get_packed_bytes(file_path))
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
