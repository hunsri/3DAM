class_name AssetExplorerHandler extends Node

@onready var v_box_container: VBoxContainer = %VBoxContainer

const ASSET_VIEW_2D_LINE = preload("uid://dg77jbtit2go")

@export var dh: DirectoryHandler

var asset_infos: Array[AssetInfo] = []

func _ready() -> void:
	reload_explorer()

func reload_explorer() -> void:
	remove_all_tiles()
	asset_infos = []
	asset_infos = fetch_assets_in_directory(dh.get_currently_open_directory())
	populate(asset_infos)

func fetch_assets_in_directory(directory: String) -> Array[AssetInfo]:
	var ret: Array[AssetInfo] = []
	
	var dir_access = DirAccess.open(directory)
	
	if dir_access == null:
		return []
	
	dir_access.list_dir_begin()
	var asset_file_name = dir_access.get_next()
	while asset_file_name != "":
		ret.append(AssetInfo.new(asset_file_name))
		asset_file_name = dir_access.get_next()
	
	return ret

func populate(assets: Array[AssetInfo]):
	add_tile_line(assets)

func add_tile_line(assets: Array[AssetInfo]) -> void:
	var tile_line:Asset_View_2D_Line = ASSET_VIEW_2D_LINE.instantiate()
	tile_line.populate(assets)
	v_box_container.add_child(tile_line)

func remove_all_tiles():
	for child in v_box_container.get_children():
		child.queue_free()
