class_name AssetExplorerHandler extends AbstractExplorerHandler

@onready var v_box_container: VBoxContainer = %VBoxContainer

@export var dh: DirectoryHandler
@export var ih: AssetInfoHandler

@export var server_handler: ServerHandler

var asset_infos: Array[AssetInfo] = []

func _ready() -> void:
	reload_explorer()

func reload_explorer() -> void:
	remove_all_tiles()
	asset_infos = []
	asset_infos = fetch_assets_info(dh.get_currently_open_directory())
	populate(asset_infos)

func asset_clicked(file_name: String) -> void:
	var asset_path = dh.get_currently_open_directory()+"/"+file_name
	ih.load_model(asset_path)

func fetch_assets_info(directory: String) -> Array[AssetInfo]:
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
	var tile_line = ResourceManager.create_tile_line()
	tile_line.set_explorer_handler(self)
	tile_line.populate(assets)
	v_box_container.add_child(tile_line)

func remove_all_tiles():
	for child in v_box_container.get_children():
		child.queue_free()
