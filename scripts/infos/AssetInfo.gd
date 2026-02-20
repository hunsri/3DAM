class_name AssetInfo extends Node

var package_name: String = ""
var version: String = "0.0.0"
var asset_file_name: String = ""
var authors: Array = []
var origin_history: Array = []
var keywords: Array = []

# utf-8 based json
var raw_json: String = ""

enum AssetType {NONE, MODEL_3D, MATERIAL, FOLDER, ASSET_PACKAGE}
var asset_type: AssetType
var _path_to_asset: String

## Initializer for AssetInfo [br]
## [param asset_path] can be ommitted if asset is on a server and no path is available
func _init(p_asset_file_name:String, asset_path: String = ""):
	
	asset_type = check_asset_type(asset_path)
	
	package_name = p_asset_file_name.get_basename()
	asset_file_name = p_asset_file_name
	
	_path_to_asset = asset_path

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

func to_json_string() -> String:
	var dict = to_dict()
	var json_string := JSON.stringify(dict, "\t")
	return json_string

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

static func from_json_string(json_string: String, asset_path: String) -> AssetInfo:
	var parsed_json:Dictionary = JSON.parse_string(json_string)
	
	if parsed_json == null:
		push_error("Failed to parse JSON for reading in asset_info")
		return null
	
	if !_is_json_valid(parsed_json):
		return null
	
	var ret := AssetInfo.new(parsed_json.package_name, asset_path)
	
	ret.version = parsed_json.version
	ret.asset_file_name = parsed_json.asset_file_name
	ret.authors = parsed_json.authors
	ret.keywords = parsed_json.keywords
	ret.origin_history = parsed_json.origin_history
	
	return ret

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
