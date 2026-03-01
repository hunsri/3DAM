class_name AssetMetaInfoDisplay extends Node

@export var comment_spawner: VBoxContainer

func _ready() -> void:
	add_comment("test_author", "test_comment with additional text")
	
func add_comment(author: String, text: String) -> void:
	comment_spawner.add_child(ResourceManager.create_comment(author, text))
