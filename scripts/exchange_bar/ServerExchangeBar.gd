## For the [code]ServerExchangeBar.tscn[/code] scene used in [code]ServerAssetBar.tscn[/code]
##
## The ServerExchangeBar is responsible for managing the assets that are currently selected for upload/download in the ServerAssetBar.
## It displays the selected assets and has a button that triggers the upload/download action in the [ServerExchangeManager].
class_name ServerExchangeBar extends Panel

## for inserting the visual asset references 
const EXCHANGE_BAR_ADDED_ASSET = preload("uid://lmanvmaaobvi")

@export var upload_button_container: PanelContainer ## upload button UI element
@export var download_button_container: PanelContainer ## download button UI element
@export var help_panel: HBoxContainer ## panel that contains the help text shown when no assets are selected for upload/download

## The container that holds the currently selected assets for upload/download. Each child is an [ExchangeBarAddedAsset]
## which contains a reference to the corresponding asset tile.
@export var added_assets_container: HBoxContainer

## Set on ready by [ServerExchangeManager], which references the [ExchangeBar] inside the [ServerAssetBar] instance.
var _exchange_manager: ServerExchangeManager

## Helper method to create an [ExchangeBarAddedAsset] [br]
## Takes an AssetTile and creates an [ExchangeBarAddedAsset] for it, which then can be given to [method ServerExchangeBar.add_to_bar].
static func create_exchange_bar_asset(p_asset_tile: AbstractAssetTile) -> ExchangeBarAddedAsset:
	var ret : ExchangeBarAddedAsset = EXCHANGE_BAR_ADDED_ASSET.instantiate()
	ret.asset_tile = p_asset_tile
	
	var image: Image = p_asset_tile.get_preview_image()
	if image != null:
		ret.set_asset_image(ImageTexture.create_from_image(image))
	return ret

## Adds the created [ExchangeBarAddedAsset] to the bar and sets the exchange mode in the [ServerExchangeManager] if this is the first asset added.
## The type of the first added asset determines the exchange mode. [br][br]
## [ServerAssetTile2D] -> Download mode [br]
## [AssetTile2D] -> Upload mode
func add_to_bar(added_asset: ExchangeBarAddedAsset) -> void:
	added_assets_container.add_child(added_asset)
	
	# we can only determine and set the exchange mode on the first element
	if added_assets_container.get_children().size() != 1:
		return
	
	if added_asset.asset_tile is ServerAssetTile2D:
		_exchange_manager.set_exchange_mode(ServerExchangeManager.ExchangeMode.DOWNLOAD)
		help_panel.visible = false
		upload_button_container.visible = false
		download_button_container.visible = true
	elif added_asset.asset_tile is AssetTile2D:
		_exchange_manager.set_exchange_mode(ServerExchangeManager.ExchangeMode.UPLOAD)
		help_panel.visible = false
		upload_button_container.visible = true
		download_button_container.visible = false

## Removes the given [ExchangeBarAddedAsset] from the bar and resets the exchange mode in the [ServerExchangeManager] if this was the last asset in the bar. [br]		
## Also resets the SELECTED status of the corresponding asset tile
func remove_from_bar(added_asset: ExchangeBarAddedAsset) -> void:
	var tile: AbstractAssetTile = added_asset.asset_tile
	var sub_logic: TileSubLogic = tile.tile_sub_logic
	if sub_logic != null:
		sub_logic.change_status(TileSubLogic.TileStatus.DEFAULT)
	
	added_assets_container.remove_child(added_asset)
	if added_assets_container.get_children().size() == 0:
		_exchange_manager.set_exchange_mode(ServerExchangeManager.ExchangeMode.NONE)
		help_panel.visible = true
		upload_button_container.visible = false
		download_button_container.visible = false

## Similiar to [method ServerExchangeBar.remove_from_bar], but for clearing the whole bar at once.
func clear_bar() -> void:
	for child in added_assets_container.get_children():
		var tile: AbstractAssetTile = child.asset_tile
		var sub_logic: TileSubLogic = tile.tile_sub_logic
		if sub_logic != null:
			sub_logic.change_status(TileSubLogic.TileStatus.DEFAULT)
		
		child.queue_free()

## Sets the reference to the [ServerExchangeManager] which is needed to set the exchange mode and trigger the upload/download
func set_server_exchange_manager(server_exchange_manager: ServerExchangeManager):
	_exchange_manager = server_exchange_manager

## Initiates the upload of the selected assets listed in the bar
func _on_upload_button_pressed() -> void:
	_exchange_manager.upload_selected_assets()

## Initiates the download of the selected assets listedin the bar
func _on_download_button_pressed() -> void:
	_exchange_manager.download_selected_assets()
