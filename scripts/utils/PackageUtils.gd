class_name PackageUtils extends Object

const PACKAGE_INFO_FILE_NAME: String = "package_info.json"

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
## Returns bool - true if successful, false upon failure
static func insert_asset_version_assets(package_path: String, asset_info: AssetInfo, zip_archive_data: PackedByteArray) -> bool:
	var dir := DirAccess.open(package_path)
	
	if asset_info == null:
		push_error("Provided asset info doesn't exist")
		return false
	
	if dir == null:
		push_error("Failed to open package at %s" % [package_path])
		return false
	
	var result := dir.make_dir(asset_info.version)
	if result == ERR_ALREADY_EXISTS:
		push_error("Version %s already exists for Package %s" % [asset_info.version, package_path])
		return false
	if result != OK:
		push_error("Failed to create Version %s for Package %s" % [asset_info.version, package_path])
		return false
	
	return AssetUtils.place_asset_zip(package_path +"/"+ asset_info.version, zip_archive_data, true, true)
