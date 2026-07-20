class_name DirectoryHandler extends Node

#@export var default_root_dir:String = "user://"
var default_root_dir:String = "res://" # change to res for web build tests; TODO NEEDS TO BE CHANGED BACK LATER
@export var default_library_name:String = "Assets"
var default_asset_path:String = default_root_dir + default_library_name
@export var explorer_handler: AssetExplorerHandler

@onready var directory_name: Button = %DirectoryName
@export var directory_tree: Tree

var _currently_open_directory = default_asset_path

func _ready() -> void:
	default_root_dir = ProjectSettings.globalize_path(default_root_dir)
	directory_name.text = default_library_name
	
	if not is_instance_valid(explorer_handler):
		push_error("No AssetExplorerHandler connected! Please connect one.")

func _open_dir_in_file_explorer() -> void:
	var abs_path: String = ProjectSettings.globalize_path(default_asset_path)
	if abs_path != "":
		OS.shell_open(abs_path)

## For clicking the head of the directory, to open the file explorer of the OS
func _on_directory_name_pressed() -> void:
	_open_dir_in_file_explorer()

## Returns the currently open path in globalized form
func get_currently_open_directory() -> String:
	
	if OS.has_feature("editor"):
		return ProjectSettings.globalize_path(_currently_open_directory)
	else:
		# Running from an exported project.
		# This is *not* identical to using `ProjectSettings.globalize_path()` with a `res://` path,
		# but is close enough in spirit.
		return OS.get_executable_path().get_base_dir().path_join(_currently_open_directory)
	
	#return ProjectSettings.globalize_path(_currently_open_directory)

func _on_tree_item_selected() -> void:
	explorer_handler.asset_sidebar_handler.reset_sidebar()
	
	_currently_open_directory = _full_path_of_item(directory_tree.get_selected())
	explorer_handler.reload_explorer()

func _full_path_of_item(item: TreeItem) -> String:
	
	var sub_path = item.get_text(0)
	var parent = item.get_parent()
	
	# adding the parent of the parent until the directory path has been consumed
	while parent != null:
		sub_path = parent.get_text(0) + "/" + sub_path
		parent = parent.get_parent()
	
	return ProjectSettings.globalize_path(default_root_dir + sub_path)

func _find_tree_item(global_path_of_dir: String) -> TreeItem:
	var sub_target_dir = global_path_of_dir.trim_prefix(default_root_dir)
	
	var item_names := sub_target_dir.split("/", false)
	
	var current_item := directory_tree.get_root()
	
	# special case: only the root is searched
	if item_names.size() == 1:
		if item_names[0] == current_item.get_text(0):
			return current_item
	else:
		item_names.remove_at(0) # removes the root
		current_item.collapsed = false
		
	for i in range(item_names.size()):
		current_item = _find_child_tree_item(current_item, item_names[i])
		if current_item == null:
			return null
		
		current_item.collapsed = false
	
	return current_item

func _find_child_tree_item(parent: TreeItem, child_name: String) -> TreeItem:
	if parent == null:
		return
	var child := parent.get_first_child()
	
	while child:
		if child.get_text(0) == child_name:
			return child
		else:
			child = child.get_next()
	
	return null
	
func open_directory(directory_path: String) -> void:
	explorer_handler.asset_sidebar_handler.reset_sidebar()
	_currently_open_directory = directory_path
	explorer_handler.reload_explorer()
	
	var item := _find_tree_item(directory_path)
	if item != null:
		item.select(0)
