## Explorer for displaying assets located on a server
##
## Responsible for fetching the assets in the currently open category from the server and populating the explorer with tiles representing those assets.
class_name ServerExplorerHandler extends AbstractExplorerHandler

@export var server_handler: ServerHandler				## enables interactions with the server
@export var category_handler: CategoryHandler			## enables interactions with the [CategorySelector] of the scene
@export var asset_sidebar_handler: AssetSidebarHandler	## enables interactions with the asset sidebar of the scene

@export var server_asset_container: MarginContainer		## contains the asset tiles

@export var status_overlay: ExplorerStatusOverlay		## overlay to disable interactions
@export var selector_overlay: SelectorStatusOverlay		## overlay to disable interactions

## asset_infos holds the AssetInfo of the assets in the currently open category on the server.
## Note that the server doesn't have a concept of directories, so there are no folder_dirs in this explorer
var asset_infos: Array[AssetInfo] = []

## on ready, the explorer is reloaded to fetch the assets in the currently open category and
## populate the explorer with tiles representing those assets.
func _ready() -> void:
	reload_explorer()

	# when the server handler has fetched the names of the assets in the currently open category
	# on_fetch_assets_info is called to update the explorer with the new information	
	server_handler.has_fetched_names_in_category.connect(on_fetch_assets_info)

## Sets the overlay of the explorer to the given exchange mode
## Used to disable interaction with the explorer while an upload or download selection is in progress
func set_overlay_status(exchange_mode: ServerExchangeManager.ExchangeMode) -> void:
	if status_overlay != null:
		status_overlay.set_overlay(exchange_mode)
	if selector_overlay != null:
		selector_overlay.set_overlay(exchange_mode)

## Calls [method reload_explorer], but first overwrites the existing asset information.
## Called after new asset_info has been fetched from the server. [br][br]
## [param asset_names] the array of asset names that was fetched from the server for the currently open category
func on_fetch_assets_info(asset_names) -> void:
	asset_infos = [] #Clear all previous entries
	
	for i in asset_names.size():
		asset_infos.append(AssetInfo.new(asset_names[i]))
	
	reload_explorer()

## Reloads the explorer by populating it with the stored [member asset_infos] from the server.
func reload_explorer() -> void:
	remove_all_tiles()
	populate(asset_infos)

## Like reload_explorer, but with fetching new information from the server first
## Leads to the call of [method on_fetch_assets_info] when the new information has been fetched, which then calls [method reload_explorer]
func reload_explorer_from_server() -> void:
	var category := category_handler.get_currently_open_category()
	if category != "":
		server_handler.fetch_package_names_in_category(category)

## Populates the explorer with tiles representing the given assets. [br][br]
## [param assets] the array of AssetInfo representing the assets that should be represented in the explorer.
func populate(assets: Array[AssetInfo]):
	add_tile_line(assets)

## Adds a tile line, containing tiles representing the given assets, to the explorer [br]
## [param assets] the server assets to create asset tiles for
func add_tile_line(assets: Array[AssetInfo]) -> void:
	var tile_line = ResourceManager.create_tile_line()
	tile_line.set_explorer_handler(self)
	tile_line.populate(assets)
	server_asset_container.add_child(tile_line)

## Removes all tiles from the explorer view.
## Called before populating the explorer with new tiles to not have old tiles mixed with the new ones.
func remove_all_tiles():
	for child in server_asset_container.get_children():
		child.queue_free()

## Called when an asset tile in the explorer is clicked. [br][br]
## Sets the latest clicked asset in the sidebar handler to the asset represented by the clicked tile,
## which then updates the asset sidebar to show the information of that asset. [br][br]
## Also fetches the comments for that asset from the server and updates the asset sidebar with it [br][br]
## [param p_asset_tile] the tile that was clicked
func asset_clicked(p_server_asset_tile: AbstractAssetTile) -> void:
	var server_asset_tile: ServerAssetTile2D = p_server_asset_tile
	asset_sidebar_handler.set_latest_clicked_asset(server_asset_tile)
	
	server_handler.fetch_package_comments(
		category_handler.get_currently_open_category(),
		server_asset_tile.asset_info.package_name,
		asset_sidebar_handler.asset_meta_info_display
	)
