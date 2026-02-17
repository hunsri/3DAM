class_name AssetInfo extends Node

var package_name: String = ""
var version: String = "0.0.0"
var asset_file_name: String = ""
var authors: Array = []
var origin_history: Array = []
var keywords: Array = []

# utf-8 based json
var raw_json: String = ""

func _init(p_package_name:String):
	package_name = p_package_name
	asset_file_name = p_package_name

func get_file_extension() -> String:
	if asset_file_name != null:
		return asset_file_name.get_extension()
	else:
		return ""

func to_dict() -> Dictionary:
	return {
		"package_name": package_name,
		"version": version,
		"asset_file_name": asset_file_name,
		"authors": authors,
		"keywords": keywords,
		"origin_history": origin_history
	}
