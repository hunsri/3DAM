## Represents an overlay to limit selection in the category or directory view
##
## Depending on the exchange mode of the view, the overlay is used to limit selection to either the local directory or the server categories
## For the explorer overview equivalent, see [ExplorerStatusOverlay] [br][br]
##
## Blocking out is done to disallow switching the directory or category selection while selecting assets, as this could lead to confusion.
## It also disallows potentially unstable actions, such as referencing unloaded assets.
class_name SelectorStatusOverlay extends PanelContainer

@export var directory_disabled_for_upload: Panel	## Panel for blocking the directory view selection, if visible
@export var category_disabled_for_download: Panel	## Panel for blocking the category view selection, if visible

enum OverlayType {Server, Local}				## Server for blocking category selection, Local for blocking directory selection
@export var overlay_type = OverlayType.Server	## The type of the overlay this class is attached to

## Sets the visibility of the overlay depending on the exchange mode of the view and the type of the overlay [br][br]
## [param exchange_mode] the exchange mode of the view, used to determine whether the overlay should be visible or not
func set_overlay(exchange_mode: ServerExchangeManager.ExchangeMode):
	match overlay_type:
		OverlayType.Server:
			set_for_server_overlay(exchange_mode)
		OverlayType.Local:
			set_for_local_overlay(exchange_mode)

## Sets visibility for the local overlay, meaning the local directory view
func set_for_local_overlay(exchange_mode: ServerExchangeManager.ExchangeMode):
	match exchange_mode:
		ServerExchangeManager.ExchangeMode.NONE:
			directory_disabled_for_upload.visible = false
		ServerExchangeManager.ExchangeMode.UPLOAD:
			directory_disabled_for_upload.visible = true
		ServerExchangeManager.ExchangeMode.DOWNLOAD:
			directory_disabled_for_upload.visible = false

## Sets visibility for the server overlay, meaning the category view of the server
func set_for_server_overlay(exchange_mode: ServerExchangeManager.ExchangeMode):
	match exchange_mode:
		ServerExchangeManager.ExchangeMode.NONE:
			category_disabled_for_download.visible = false
		ServerExchangeManager.ExchangeMode.UPLOAD:
			category_disabled_for_download.visible = false
		ServerExchangeManager.ExchangeMode.DOWNLOAD:
			category_disabled_for_download.visible = true
