class_name DirectoryHandler extends Node

@export var default_root_dir:String = "user://"
@export var default_library_name:String = "Assets"
var default_asset_path:String = default_root_dir + default_library_name
@export var explorer_handler: AssetExplorerHandler

@onready var directory_name: Button = %DirectoryName
@export var directory_tree: Tree

var _currently_open_directory = default_asset_path

func _ready() -> void:
	directory_name.text = default_library_name
	
	if not is_instance_valid(explorer_handler):
		push_error("No AssetExplorerHandler connected! Please connect one.")

func _open_dir_in_explorer() -> void:
	var abs_path: String = ProjectSettings.globalize_path(default_asset_path)
	if abs_path != "":
		OS.shell_open(abs_path)

func _on_directory_name_pressed() -> void:
	_open_dir_in_explorer()

## Returns the currently open path in globalized form
func get_currently_open_directory() -> String:
	return ProjectSettings.globalize_path(_currently_open_directory)

func _on_tree_item_selected() -> void:
	var sub_path = directory_tree.get_selected().get_text(0)
	
	var parent = directory_tree.get_selected().get_parent()
	
	while parent != null:
		sub_path = parent.get_text(0) + "/" + sub_path
		parent = parent.get_parent()
	
	_currently_open_directory = default_root_dir + sub_path
	explorer_handler.reload_explorer()
