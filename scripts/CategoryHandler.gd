class_name CategoryHandler extends Node

@onready var server_name: Button = %ServerName
@export var server_handler: ServerHandler
@export var category_selector: CategorySelector

var server_categories: Array

var _currently_selected_category: String

func _ready() -> void:
	await server_handler.has_fetched_from_server
	
	server_name.text = server_handler.get_server_name()
	server_categories = server_handler.get_asset_category()
	
	category_selector.draw_tree(server_categories)
	category_selector.force_selection_of_first_child()
	
func get_currently_open_category() -> String:
	return _currently_selected_category

func _on_category_explorer_item_selected() -> void:
	_currently_selected_category = category_selector.get_selected().get_text(0)
	server_handler.fetch_package_names_in_category(_currently_selected_category)
	server_handler.server_exchange_manager.asset_explorer_handler.asset_sidebar_handler.reset_sidebar()
