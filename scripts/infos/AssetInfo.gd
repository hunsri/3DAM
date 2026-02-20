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

## Returns the globalized path to the asset, as long as it is a local asset
func get_path_to_local_asset() -> String:
	return ProjectSettings.globalize_path(_path_to_asset)
