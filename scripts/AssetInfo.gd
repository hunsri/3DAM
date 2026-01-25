class_name AssetInfo extends Node

var package_name: String = ""

var id: String = ""
var version: String = ""
var asset_file_name: String = ""
var authors: Array[String] = []
var origin: String = ""
var asset_history: Array[String]
var keywords: Array[String]


func _init(p_package_name:String):
	package_name = p_package_name
	asset_file_name = p_package_name
