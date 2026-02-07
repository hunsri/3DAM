class_name ExplorerStatusOverlay extends PanelContainer

@export var server_asset_selection_disabled: PanelContainer
@export var local_asset_selection_disabled: PanelContainer

enum OverlayType {Server, Local}
@export var overlay_type = OverlayType.Server

func set_overlay(exchange_mode: ServerExchangeManager.ExchangeMode):
	match overlay_type:
		OverlayType.Server:
			set_for_server_overlay(exchange_mode)
		OverlayType.Local:
			set_for_local_overlay(exchange_mode)
	
	
func set_for_local_overlay(exchange_mode: ServerExchangeManager.ExchangeMode):
	match exchange_mode:
		ServerExchangeManager.ExchangeMode.NONE:
			local_asset_selection_disabled.visible = false
		ServerExchangeManager.ExchangeMode.UPLOAD:
			local_asset_selection_disabled.visible = false
		ServerExchangeManager.ExchangeMode.DOWNLOAD:
			local_asset_selection_disabled.visible = true

func set_for_server_overlay(exchange_mode: ServerExchangeManager.ExchangeMode):
	match exchange_mode:
		ServerExchangeManager.ExchangeMode.NONE:
			server_asset_selection_disabled.visible = false
		ServerExchangeManager.ExchangeMode.UPLOAD:
			server_asset_selection_disabled.visible = true
		ServerExchangeManager.ExchangeMode.DOWNLOAD:
			server_asset_selection_disabled.visible = false
