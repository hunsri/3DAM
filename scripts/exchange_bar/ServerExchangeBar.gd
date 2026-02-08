class_name ServerExchangeBar extends Panel

const EXCHANGE_BAR_ADDED_ASSET = preload("uid://lmanvmaaobvi")

@export var added_assets_container: HBoxContainer
var _exchange_manager: ServerExchangeManager

static func create_exchange_bar_asset(p_asset_tile: AbstractAssetTile) -> ExchangeBarAddedAsset:
	var ret : ExchangeBarAddedAsset = EXCHANGE_BAR_ADDED_ASSET.instantiate()
	ret.asset_tile = p_asset_tile
	return ret

func add_to_bar(added_asset: ExchangeBarAddedAsset) -> void:
	added_assets_container.add_child(added_asset)
	
	# we can only determine and set the exchange mode on the first element
	if added_assets_container.get_children().size() != 1:
		return
	
	if added_asset.asset_tile is ServerAssetTile2D:
		_exchange_manager.set_exchange_mode(ServerExchangeManager.ExchangeMode.DOWNLOAD)
	elif added_asset.asset_tile is AssetTile2D:
		_exchange_manager.set_exchange_mode(ServerExchangeManager.ExchangeMode.UPLOAD)

func remove_from_bar(added_asset: ExchangeBarAddedAsset) -> void:
	added_assets_container.remove_child(added_asset)
	
	if added_assets_container.get_children().size() == 0:
		_exchange_manager.set_exchange_mode(ServerExchangeManager.ExchangeMode.NONE)

func clear_bar() -> void:
	for child in added_assets_container.get_children():
		child.queue_free()

func set_server_exchange_manager(server_exchange_manager: ServerExchangeManager):
	_exchange_manager = server_exchange_manager


func _on_upload_button_pressed() -> void:
	_exchange_manager.upload_selected_assets()

func _on_download_button_pressed() -> void:
	_exchange_manager.download_selected_assets()
