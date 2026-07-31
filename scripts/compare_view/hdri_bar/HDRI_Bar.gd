class_name HDRI_Bar extends Node

@onready var compare_3d_view_manager: Compare3DViewManager = $"../.."
@onready var hdri_item_root: HBoxContainer = $ScrollContainer/HDRI_item_root

const HDRI_DIR := "res://hdris/hdri_files/"
const HDRI_ITEM = preload("uid://yhtsavcsk61a")

func _ready() -> void:
	load_hdris()

func load_hdris() -> void:
	
	for path in get_hdr_files():
		add_hdri_item(path)

func add_hdri_item(path_to_hdri: String) -> void:
	var hdri_item: HDRI_Item = HDRI_ITEM.instantiate()
	hdri_item.setup(path_to_hdri)
	
	hdri_item_root.add_child(hdri_item)

func get_hdr_files() -> PackedStringArray:
	var files := PackedStringArray()
	var dir := DirAccess.open(HDRI_DIR)
	if dir == null:
		return files

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if !dir.current_is_dir() and file_name.get_extension().to_lower() == "hdr":
			files.append(HDRI_DIR.path_join(file_name))
		file_name = dir.get_next()
	dir.list_dir_end()

	return files
