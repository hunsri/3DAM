class_name FolderTile extends Node

@export var folder_name_label: Label

var asset_handler: AssetExplorerHandler
var folder_path: String

func setup_tile(p_asset_handler: AbstractExplorerHandler, p_folder_path: String) -> void:
	folder_path = p_folder_path
	asset_handler = p_asset_handler
	
	folder_name_label.text = p_folder_path.rstrip("/").get_file()
	
func _on_folder_button_pressed() -> void:
	asset_handler.directory_handler.open_directory(folder_path)
