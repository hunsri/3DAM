class_name PackageUtils extends Object

const PACKAGE_INFO_FILE_NAME: String = "package_info.json"
const ASSET_DIR_NAME: String = "assets"

## Creates a package directory with package_info.json [br]
## Returns String - path to the new package or empty string "" upon failure
static func create_new_package(package_info: PackageInfo, package_location: String) -> String:
	var dir := DirAccess.open(package_location)
	
	if package_info == null:
		push_error("Provided package info doesn't exist")
		return ""
	
	if dir == null:
		push_error("Failed to open parent directory when creating package: %s" % package_location)
		return ""
	
	var package_name := package_info.package_name
	var result := dir.make_dir(package_name)
	if result == ERR_ALREADY_EXISTS:
		push_error("Package %s already exists under %s" % [package_name, package_location])
		return ""
	if result != OK:
		push_error("Failed to create Package %s under %s" % [package_name, package_location])
		return ""
	
	var package_path = package_location + "/"+ package_name
	if _create_package_info_file_in_package(package_info, package_path):
		return package_path
	
	return ""

## Creates a package info file for creating a new package
static func _create_package_info_file_in_package(package_info: PackageInfo, package_path: String) -> bool:
	var file := FileAccess.open(package_path +"/"+ PACKAGE_INFO_FILE_NAME, FileAccess.WRITE)
	
	if file == null:
		push_error("Failed to open file for writing: %s" % package_path)
		return false
	
	file.store_string(package_info.to_json_string())
	file.close()
	return true

## Creates the asset version as directory into a package
## The directory name is the version provided in [param asset_info] [br]
## Returns String - path to the asset version, empty String "" upon failure
static func insert_package_version_assets(package_path: String, asset_info: AssetInfo, zip_archive_data: PackedByteArray) -> String:
	var dir := DirAccess.open(package_path)
	
	if asset_info == null:
		push_error("Provided asset info doesn't exist")
		return ""
	
	if dir == null:
		push_error("Failed to open package at %s" % [package_path])
		return ""
	
	var result := dir.make_dir(asset_info.version)
	if result == ERR_ALREADY_EXISTS:
		push_error("Version %s already exists for Package %s" % [asset_info.version, package_path])
		return ""
	if result != OK:
		push_error("Failed to create Version %s for Package %s" % [asset_info.version, package_path])
		return ""
	
	var asset_version_path := package_path +"/"+ asset_info.version
	
	if AssetUtils.place_asset_zip(asset_version_path, zip_archive_data):
		return asset_version_path
	
	return ""

## Checks whether the given target is a package
## Returns bool - true if a package_info can be found within the path
static func is_target_package(target_path: String) -> bool:
	var dir := DirAccess.open(target_path)
	
	if dir == null:
		return false
	
	if dir.file_exists(PACKAGE_INFO_FILE_NAME):
		return true
	
	return false

## Loads the package info of the provided package
## [param package_root_path] - path to the package
## Returns the PackageInfo
static func load_package_info_from_root(package_root_path: String) -> PackageInfo:
	var file := FileAccess.open(package_root_path +"/"+ PACKAGE_INFO_FILE_NAME, FileAccess.READ)
	
	if file == null:
		push_error("Failed to load package info from package %s" % [package_root_path])
		return null
	
	var package_info_string: String = file.get_as_text()
	file.close()
	
	return PackageInfo.from_json_string(package_info_string)

static func load_package_version_asset_info_from_root(package_root_path: String, package_version: String) -> AssetInfo:
	var file := FileAccess.open(package_root_path +"/"+ package_version +"/"+ AssetUtils.ASSET_INFO_FILE_NAME, FileAccess.READ)
	
	if file == null:
		push_error("Failed to load asset info from package %s in version %s" % [package_root_path, package_version])
		return null
	
	var asset_info_string: String = file.get_as_text()
	file.close()
	
	return AssetInfo.from_json_string(asset_info_string, package_root_path +"/"+ package_version)

## Returns true if the version directory and the asset_info inside it can be found
static func does_package_version_exist(package_root_path: String, version_name: String):
	var suspected_asset_info_file_path = package_root_path + "/"+ version_name +"/"+ AssetUtils.ASSET_INFO_FILE_NAME
	return FileAccess.file_exists(suspected_asset_info_file_path)

## Returns the path to the latest version that is available within the package
static func get_latest_available_package_version(package_root_path: String, as_full_path: bool) -> String:
	if not PackageUtils.is_target_package(package_root_path):
		return ""
	
	var available_versions = load_package_info_from_root(package_root_path).versions
	
	available_versions.reverse() # so that latest version is at index 0
	
	for version in available_versions:
		if does_package_version_exist(package_root_path, version):
			if as_full_path:
				return package_root_path +"/"+ version
			else:
				return version
	
	return "" # in case no package version can be found

## [param path_to_version_directory] - the path to the specific version of a package [br]
## Returns the path to the main model asset of the package version
static func get_path_to_model_asset(path_to_version_directory: String) -> String:
	var asset_info_path := path_to_version_directory + "/" + AssetUtils.ASSET_INFO_FILE_NAME 
	var file_access = FileAccess.open(asset_info_path, FileAccess.READ)
	
	if file_access == null:
		return ""
	
	var parsed_json:Dictionary = JSON.parse_string(file_access.get_as_text())
	
	if parsed_json == null:
		push_error("Failed to parse JSON for reading in asset_info")
		return ""
	
	if parsed_json.has("asset_file_name") == false:
		return ""
	
	return path_to_version_directory + "/" + ASSET_DIR_NAME + "/" + parsed_json.asset_file_name
