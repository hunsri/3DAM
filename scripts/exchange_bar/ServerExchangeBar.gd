class_name ServerExchangeBar extends Panel

const EXCHANGE_BAR_ADDED_ASSET = preload("uid://lmanvmaaobvi")

@export var added_assets_container: HBoxContainer
var _exchange_manager: ServerExchangeManager

## a false value represents upload mode
var is_in_download_mode = true

static func create_exchange_bar_asset() -> ExchangeBarAddedAsset:
	return EXCHANGE_BAR_ADDED_ASSET.instantiate()

func add_to_bar(added_asset: ExchangeBarAddedAsset) -> void:
	added_assets_container.add_child(added_asset)

func remove_from_bar(added_asset: ExchangeBarAddedAsset) -> void:
	added_assets_container.remove_child(added_asset)

func clear_bar() -> void:
	for child in added_assets_container.get_children():
		child.queue_free()

func _on_upload_mode_button_pressed() -> void:
	is_in_download_mode = false

func _on_download_mode_button_pressed() -> void:
	is_in_download_mode = true

func _on_load_action_button_pressed() -> void:
	if is_in_download_mode:
		_exchange_manager.download_selected_assets()

func set_server_exchange_manager(server_exchange_manager: ServerExchangeManager):
	_exchange_manager = server_exchange_manager
