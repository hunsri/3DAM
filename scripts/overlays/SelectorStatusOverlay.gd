class_name SelectorStatusOverlay extends PanelContainer

@export var directory_disabled_for_upload: Panel
@export var category_disabled_for_download: Panel

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
			directory_disabled_for_upload.visible = false
		ServerExchangeManager.ExchangeMode.UPLOAD:
			directory_disabled_for_upload.visible = true
		ServerExchangeManager.ExchangeMode.DOWNLOAD:
			directory_disabled_for_upload.visible = false

func set_for_server_overlay(exchange_mode: ServerExchangeManager.ExchangeMode):
	match exchange_mode:
		ServerExchangeManager.ExchangeMode.NONE:
			category_disabled_for_download.visible = false
		ServerExchangeManager.ExchangeMode.UPLOAD:
			category_disabled_for_download.visible = false
		ServerExchangeManager.ExchangeMode.DOWNLOAD:
			category_disabled_for_download.visible = true
