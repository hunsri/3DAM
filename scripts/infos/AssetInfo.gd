## Class for representing asset information
class_name AssetInfo extends Node

var package_name: String = ""		## the name of the package the asset belongs to
var version: String = "0.0.0"		## the version of the asset
var asset_file_name: String = ""	## the file name of the asset with extension, e.g. "my_model.glb"
var authors: Array = []				## the authors of the asset, can be empty if no author is specified
var origin_history: Array = []		## the history of the asset, where it came from, can be empty if no history is specified
var keywords: Array = []			## the keywords associated with the asset, can be empty if no keywords are specified

# utf-8 based json
var raw_json: String = ""			## the raw json string used for serialization, can be empty if not set

enum AssetType {NONE, MODEL_3D, MATERIAL, FOLDER, ASSET_PACKAGE}	## categorizes the underlying type of the asset
var asset_type: AssetType = AssetType.NONE							## the type of the asset, can be NONE if the type cannot be determined
var _path_to_asset: String = ""										## the path to the asset, can be empty if asset is on a server and no path is available	
var _paths_to_dependencies: Array[String] = []						## the paths to the dependencies of the asset, can be empty

## Initializer for AssetInfo [br]
## [param asset_path] can be ommitted if asset is on a server and no path is available
func _init(p_asset_file_name:String, asset_path: String = ""):
	
	asset_type = check_asset_type(asset_path)
	
	package_name = p_asset_file_name.get_basename()
	asset_file_name = p_asset_file_name
	
	_path_to_asset = asset_path
	if asset_path != "":
		_paths_to_dependencies = ModelLoader.get_dependencies(asset_path)

## Returns the file extension of the asset, if it has one, otherwise an empty string
func get_file_extension() -> String:
	if asset_file_name != null:
		return asset_file_name.get_extension()
	else:
		return ""

## Returns a dictionary with all members used in the serialization of AssetInfo
func to_dict() -> Dictionary:
	return {
		"package_name": package_name,
		"version": version,
		"asset_file_name": asset_file_name,
		"authors": authors,
		"keywords": keywords,
		"origin_history": origin_history
	}

## Returns a json string with all members used in the serialization of AssetInfo
func to_json_string() -> String:
	var dict = to_dict()
	var json_string := JSON.stringify(dict, "\t")
	return json_string

## Checks the type of the asset based on the file path, if it is a folder, an asset package or a 3D model.
## If the file path is empty or the type cannot be determined, AssetType.NONE is returned [br][br]
## [param file_path] the path to the asset [br]
## Returns the type of the asset as AssetType
func check_asset_type(file_path: String) -> AssetType:
	if file_path == "":
		asset_type = AssetType.NONE
	
	var dir := DirAccess.open(file_path)
	if dir != null: #if a directory is found
		if PackageUtils.is_target_package(file_path):
			return AssetType.ASSET_PACKAGE
		else:
			return AssetType.FOLDER
	
	if(AssetUtils.is_file_3D_model(file_path)):
		return AssetType.MODEL_3D
		
	return AssetType.NONE

## For extracting the AssetInfo from a packages asset_info.json [br]
## Assumes that the given json stems from a package [br]
static func from_json_string(json_string: String, package_asset_version_directory: String) -> AssetInfo:
	var parsed_json:Dictionary = JSON.parse_string(json_string)
	
	if parsed_json == null:
		push_error("Failed to parse JSON for reading in asset_info")
		return null
	
	if !_is_json_valid(parsed_json):
		return null
	
	var asset_path = package_asset_version_directory + "/" + PackageUtils.ASSET_DIR_NAME+ "/" + parsed_json.asset_file_name
	var ret := AssetInfo.new(parsed_json.package_name, asset_path)
	
	ret.version = parsed_json.version
	ret.asset_file_name = parsed_json.asset_file_name
	ret.authors = parsed_json.authors
	ret.keywords = parsed_json.keywords
	ret.origin_history = parsed_json.origin_history
	
	return ret

## Checks if the given json contains all necessary keys for creating an AssetInfo [br]
## The required keys are: "package_name", "version", "asset_file_name", "authors", "keywords", "origin_history" [br][br]
## [param json] the json to check [br]
## Returns true if the json is valid, false otherwise
static func _is_json_valid(json: Dictionary) -> bool:
	var keys: Array = ["package_name", "version", "asset_file_name", "authors", "keywords", "origin_history"]
	
	for key in keys:
		if !json.has(key):
			push_error("Couldn't find key %s in json" % key)
			return false
	return true

## Returns the globalized path to the asset, as long as it is a local asset
func get_path_to_local_asset() -> String:
	return ProjectSettings.globalize_path(_path_to_asset)

## Returns the dependencies as relative path to the main asset
func get_path_to_local_dependencies_relative() -> Array[String]:
	return _paths_to_dependencies.duplicate(true)

## Returns the dependencies as globalized path
func get_path_to_local_dependencies_globalized() -> Array[String]:
	var ret = get_path_to_local_dependencies_relative().duplicate(true)
	
	for i in ret.size():
		ret[i] = _path_to_asset.get_base_dir() + "/" + ret[i] # converting from relative to global
	return ret
