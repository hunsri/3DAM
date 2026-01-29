class_name ServerAssetTile2D extends AbstractAssetTile

@export var asset_name_label: Label
@export var asset_preview: TextureRect
@export var tile_sub_logic: TileSubLogic

var asset_handler: ServerExplorerHandler
var asset_info: AssetInfo

func setup_tile(p_asset_handler: AbstractExplorerHandler, p_asset_info: AssetInfo):
	asset_handler = p_asset_handler
	asset_info = p_asset_info
	asset_name_label.text = asset_info.package_name
	
	asset_handler.server_handler.fetch_asset_preview(
		asset_handler.category_handler.get_currently_open_category(),
		asset_info.package_name, 
		self)

func on_request_completed_fetch_asset_info(_result, _response_code, _headers, body):
	if _response_code != 200:
		return
	
	var json = JSON.parse_string(body.get_string_from_utf8())
	asset_info.id = json["id"]
	asset_info.version = json["version"]
	asset_info.asset_file_name = json["asset_file_name"]
	asset_info.authors = json["authors"]
	asset_info.origin = json["origin"]
	asset_info.origin_history = json["origin_history"]
	asset_info.keywords = json["keywords"]
	
	var is_supported = AssetUtils.is_file_supported(asset_info.asset_file_name)
	tile_sub_logic.set_is_supported_asset(is_supported)

func on_request_completed_fetch_asset_preview(_result, _response_code, _headers, body):
	if _response_code != 200:
		return
	
	var image = Image.new()
	var err = image.load_png_from_buffer(body)
	if err == OK:
		var texture := ImageTexture.new()
		texture = ImageTexture.create_from_image(image)
		
		asset_preview.texture = texture
	
	# Fetching remaining meta information
	asset_handler.server_handler.fetch_asset_info(
		asset_handler.category_handler.get_currently_open_category(),
		asset_info.package_name,
		self
	)

func _on_asset_clicked_button_pressed() -> void:
	pass # Replace with function body.

func _on_selection_checkbox_pressed() -> void:
	if is_selected():
		asset_handler.server_handler.server_exchange_manager.add_to_selection(self)
	else:
		asset_handler.server_handler.server_exchange_manager.remove_from_selection(self)
	
func is_selected() -> bool:
	return tile_sub_logic.selected.button_pressed
