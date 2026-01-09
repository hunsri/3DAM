class_name CategoryHandler extends Node

@onready var server_name: Button = %ServerName
@onready var category_tree: Tree = %CategoryTree
@export var server_handler: ServerHandler

var _currently_open_category: String = ""

func _ready() -> void:
	server_name.text = await server_handler.get_server_name()
	
	
