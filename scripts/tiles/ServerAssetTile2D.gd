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
	
	# Fetching the rest of the asset_info, since it is not complete at this point
	asset_handler.server_handler.fetch_asset_info(
		asset_handler.category_handler.get_currently_open_category(),
		asset_info.package_name,
		self
	)
	
	asset_handler.server_handler.fetch_asset_preview(
		asset_handler.category_handler.get_currently_open_category(),
		asset_info.package_name, 
		self)
	
	# all assets on a server are packages 
	tile_sub_logic.set_is_package(true)
	tile_sub_logic.is_local = false

func on_request_completed_fetch_asset_info(_result, _response_code, _headers, body):
	if _response_code != 200:
		return
	
	var json = JSON.parse_string(body.get_string_from_utf8())
	asset_info.package_name = json["package_name"]
	asset_info.version = json["version"]
	asset_info.asset_file_name = json["asset_file_name"]
	asset_info.authors = json["authors"]
	asset_info.origin_history = json["origin_history"]
	asset_info.keywords = json["keywords"]
	
	asset_info.raw_json = body.get_string_from_utf8()
	
	var is_supported = AssetUtils.is_file_name_supported(asset_info.asset_file_name)
	tile_sub_logic.set_is_supported_asset(is_supported)
	tile_sub_logic.set_file_extension(asset_info.asset_file_name.get_extension())

func on_request_completed_fetch_asset_preview(_result, _response_code, _headers, body):
	if _response_code != 200:
		return
	
	var image = Image.new()
	var err = image.load_png_from_buffer(body)
	if err == OK:
		var texture := ImageTexture.new()
		texture = ImageTexture.create_from_image(image)
		
		asset_preview.texture = texture
	
	asset_handler.server_handler.fetch_package_faves(
		asset_handler.category_handler.get_currently_open_category(),
		asset_info.package_name,
		self
		)

func on_request_completed_fetch_package_faves(_result, response_code, _headers, body):
	if response_code != 200:
		return
	
	var body_json = JSON.parse_string(body.get_string_from_utf8())
	if body_json == null:
		return
	
	var has_faved: bool
	var fave_count: int
		
	if body_json.has("user_has_favorited"):
		if (typeof(body_json["user_has_favorited"]) == TYPE_BOOL):
			has_faved = body_json["user_has_favorited"]
	
	if body_json.has("favorites_count"):
		if (typeof(body_json["favorites_count"]) == TYPE_FLOAT): #numerals are float in json
			fave_count = int(body_json["favorites_count"]) #but we can convert back to int
	
	tile_sub_logic.set_faved(has_faved)
	tile_sub_logic.set_fave_counter(fave_count)

func on_request_completed_faving_package(_result, response_code, _headers, _body):
	if response_code != 200:
		return
	
	# could be handled through a response instead if server provides it in the future
	asset_handler.server_handler.fetch_package_faves(
		asset_handler.category_handler.get_currently_open_category(),
		asset_info.package_name,
		self
		)

func _on_asset_clicked_button_pressed() -> void:
	asset_handler.asset_clicked(self)

func _on_selection_checkbox_pressed() -> void:
	if is_selected():
		asset_handler.server_handler.server_exchange_manager.add_to_selection(self)
	else:
		asset_handler.server_handler.server_exchange_manager.remove_from_selection(self)
	
func is_selected() -> bool:
	return tile_sub_logic.selected.button_pressed

func get_asset_info() -> AssetInfo:
	return asset_info

func _on_fave_button_pressed() -> void:
	if tile_sub_logic._is_faved:
		asset_handler.server_handler.fave_package(
			asset_handler.category_handler.get_currently_open_category(), 
			asset_info.package_name,
			self
			)
	else:
		asset_handler.server_handler.unfave_package(
			asset_handler.category_handler.get_currently_open_category(), 
			asset_info.package_name,
			self
			)
