class_name ServerExplorerHandler extends AbstractExplorerHandler

@export var server_handler: ServerHandler
@export var category_handler: CategoryHandler
@export var asset_sidebar_handler: AssetSidebarHandler

@onready var v_box_container: VBoxContainer = %VBoxContainerServer

@export var status_overlay: ExplorerStatusOverlay
@export var selector_overlay: SelectorStatusOverlay

var asset_infos: Array[AssetInfo] = []

func _ready() -> void:
	reload_explorer()
	
	server_handler.has_fetched_names_in_category.connect(on_fetch_assets_info)

func set_overlay_status(exchange_mode: ServerExchangeManager.ExchangeMode) -> void:
	if status_overlay != null:
		status_overlay.set_overlay(exchange_mode)
	if selector_overlay != null:
		selector_overlay.set_overlay(exchange_mode)

func on_fetch_assets_info(asset_names):
	asset_infos = [] #Clear all previous entries
	
	for i in asset_names.size():
		asset_infos.append(AssetInfo.new(asset_names[i]))
	
	reload_explorer()

func reload_explorer() -> void:
	remove_all_tiles()
	populate(asset_infos)

## Like reload_explorer, but with fetching new information first
func reload_explorer_from_server() -> void:
	var category := category_handler.get_currently_open_category()
	if category != "":
		server_handler.fetch_package_names_in_category(category)

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

func asset_clicked(p_server_asset_tile: AbstractAssetTile) -> void:
	var server_asset_tile: ServerAssetTile2D = p_server_asset_tile
	asset_sidebar_handler.set_latest_clicked_asset(server_asset_tile)
	
	server_handler.fetch_package_comments(
		category_handler.get_currently_open_category(),
		server_asset_tile.asset_info.package_name,
		asset_sidebar_handler.asset_meta_info_display
	)
