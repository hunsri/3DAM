class_name AssetInfo extends Node

var package_name: String = ""

var id: String = ""
var version: String = ""
var asset_file_name: String = ""
var authors: Array = []
var origin: String = ""
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
