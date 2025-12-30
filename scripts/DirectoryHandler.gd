class_name DirectoryHandler extends Node

@export var default_root_dir:String = "user://"
@export var default_library_name:String = "Assets"
var default_asset_path:String = default_root_dir + default_library_name

@onready var directory_name: Button = %DirectoryName

func _ready() -> void:
	directory_name.text = default_library_name

func _open_dir_in_explorer() -> void:
	var abs_path: String = ProjectSettings.globalize_path(default_asset_path)
	if abs_path != "":
		OS.shell_open(abs_path)

func _on_directory_name_pressed() -> void:
	_open_dir_in_explorer()
