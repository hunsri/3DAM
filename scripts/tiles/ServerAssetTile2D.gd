class_name ServerAssetTile2D extends AbstractAssetTile

@export var asset_name_label: Label
@export var asset_preview: TextureRect
@export var tile_sub_logic: TileSubLogic

var asset_handler: ServerExplorerHandler
var asset_info: AssetInfo

func setup_tile(p_asset_handler: AbstractExplorerHandler, p_asset_info: AssetInfo):
	asset_handler = p_asset_handler
	asset_info = p_asset_info
	asset_name_label.text = asset_info.asset_name
	
	var is_supported = AssetUtils.is_file_supported(asset_info.asset_name)
	tile_sub_logic.set_is_supported_asset(is_supported)
	
	asset_handler.server_handler.fetch_asset_preview(
		asset_handler.category_handler.get_currently_open_category(),
		asset_info.asset_name, 
		self)

func on_request_completed_fetch_asset_preview(_result, _response_code, _headers, body):
	if _response_code != 200:
		return
	
	var image = Image.new()
	var err = image.load_png_from_buffer(body)
	if err == OK:
		var texture := ImageTexture.new()
		texture = ImageTexture.create_from_image(image)
		
		asset_preview.texture = texture
