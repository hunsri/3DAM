## Represents an overlay to limit selection in the explorer overview
##
## Depending on the exchange mode of the view, the overlay is used to limit selection to either the local assets or the server assets in the explorer overview
## For the selector equivalent (directory and category views), see [SelectorStatusOverlay] [br][br]
## 
## Blocking out is done to limit selection to the relevant assets for the current exchange mode to avoid confusion for the user.
## It also disallows illegal actions, such as selecting an asset for upload when in download mode.
class_name ExplorerStatusOverlay extends PanelContainer

@export var server_asset_selection_disabled: PanelContainer	## panel for blocking the server asset selection, if visible
@export var local_asset_selection_disabled: PanelContainer	## panel for blocking the local asset selection, if visible

enum OverlayType {Server, Local}				## Server for blocking server asset selection, Local for blocking local asset selection
@export var overlay_type = OverlayType.Server	## The type of the overlay this class is attached to

## Sets the visibility of the overlay depending on the exchange mode of the view and the type of the overlay [br][br]
## [param exchange_mode] the exchange mode of the view, used to determine whether the overlay should be visible or not
func set_overlay(exchange_mode: ServerExchangeManager.ExchangeMode):
	match overlay_type:
		OverlayType.Server:
			set_for_server_overlay(exchange_mode)
		OverlayType.Local:
			set_for_local_overlay(exchange_mode)
	
## Sets visibility for the local overlay, meaning the local asset selection in the explorer overview
func set_for_local_overlay(exchange_mode: ServerExchangeManager.ExchangeMode):
	match exchange_mode:
		ServerExchangeManager.ExchangeMode.NONE:
			local_asset_selection_disabled.visible = false
		ServerExchangeManager.ExchangeMode.UPLOAD:
			local_asset_selection_disabled.visible = false
		ServerExchangeManager.ExchangeMode.DOWNLOAD:
			local_asset_selection_disabled.visible = true

## Sets visibility for the server overlay, meaning the server asset selection in the explorer overview
func set_for_server_overlay(exchange_mode: ServerExchangeManager.ExchangeMode):
	match exchange_mode:
		ServerExchangeManager.ExchangeMode.NONE:
			server_asset_selection_disabled.visible = false
		ServerExchangeManager.ExchangeMode.UPLOAD:
			server_asset_selection_disabled.visible = true
		ServerExchangeManager.ExchangeMode.DOWNLOAD:
			server_asset_selection_disabled.visible = false
