class_name ServerExplorerHandler extends AbstractExplorerHandler

@export var server_handler: ServerHandler

@onready var v_box_container: VBoxContainer = %VBoxContainerServer

var asset_infos: Array[AssetInfo] = []

func _ready() -> void:
	reload_explorer()
	
	server_handler.has_fetched_names_in_category.connect(on_fetch_assets_info)

func on_fetch_assets_info(asset_names) -> Array[AssetInfo]:
	var ret: Array[AssetInfo] = []
	
	print(asset_names)
	
	for i in asset_names.size():
		ret.append(AssetInfo.new(asset_names[i]))
	
	return ret

func reload_explorer() -> void:
	remove_all_tiles()
	asset_infos = []
	populate(asset_infos)

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
