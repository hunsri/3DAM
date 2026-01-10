class_name CategoryHandler extends Node

@onready var server_name: Button = %ServerName
@onready var category_tree: Tree = %CategoryTree
@export var server_handler: ServerHandler
@export var category_explorer: CategoryExplorer

var server_categories: Array

func _ready() -> void:
	#server_handler.waiting_for_data()
	await server_handler.has_fetched_from_server
	
	server_name.text = server_handler.get_server_name()
	server_categories = server_handler.get_asset_category()
	
	category_explorer.draw_tree(server_categories)
	
	
func _on_category_explorer_item_selected() -> void:
	print(category_explorer.get_selected().get_text(0))
