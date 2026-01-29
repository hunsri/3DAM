class_name ServerExchangeBar extends Panel

const EXCHANGE_BAR_ADDED_ASSET = preload("uid://lmanvmaaobvi")

@export var added_assets_container: HBoxContainer

static func create_exchange_bar_asset() -> ExchangeBarAddedAsset:
	return EXCHANGE_BAR_ADDED_ASSET.instantiate()

func add_to_bar(added_asset: ExchangeBarAddedAsset) -> void:
	added_assets_container.add_child(added_asset)

func remove_from_bar(added_asset: ExchangeBarAddedAsset) -> void:
	added_assets_container.remove_child(added_asset)

func clear_bar() -> void:
	for child in added_assets_container.get_children():
		child.queue_free()
	
