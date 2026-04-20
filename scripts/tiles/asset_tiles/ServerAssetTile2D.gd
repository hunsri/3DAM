## Represents a remotely stored asset as a 2Dimensional tile in the AssetExplorerView.
##
## Represents asset packages on a server.
## Responsible for initiating the fetching of asset data from the server and processing the server response.
## For local assets, see [AssetTile2D].
class_name ServerAssetTile2D extends AbstractAssetTile

@export var asset_name_label: Label			## the label that displays the name of the asset
@export var asset_preview: TextureRect		## the TextureRect that displays the preview of the asset
@export var tile_sub_logic: TileSubLogic	## contains state information about the tile, such as whether it's highlighted or selected

var asset_handler: ServerExplorerHandler	## used to access instances of related handlers and to communicate if the tile is interacted with
var asset_info: AssetInfo					## contains information about the represented asset
var preview_image: Image					## contains the preview image of the represented asset

## Sets up the tile with the given asset info and asset handler.
## Also fetches the rest of the asset info and the preview of the asset from the server, since at this point we only have the package name.[br][br]
## [color=blue]Note:[/color] This function needs to be called after instantiating the tile and before adding it to the view
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

## Callback for when the request for fetching the asset info is completed. [br][br]
## The response from the server is processed and the asset info of the tile is updated accordingly.
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

## Callback for when the request for fetching the asset preview is completed.
## Processes the response from the server and displays the preview of the asset in the tile. [br][br]
## Also initiates request for the favorite information
func on_request_completed_fetch_asset_preview(_result, _response_code, _headers, body):
	if _response_code != 200:
		return
	
	var image = Image.new()
	var err = image.load_png_from_buffer(body)
	if err == OK:
		var texture := ImageTexture.new()
		texture = ImageTexture.create_from_image(image)
		
		preview_image = image
		asset_preview.texture = texture
	
	asset_handler.server_handler.fetch_package_faves(
		asset_handler.category_handler.get_currently_open_category(),
		asset_info.package_name,
		self
		)

## Callback for when the request for fetching the favorite information of the package is completed.
## The response from the server is processed and the favorite information of the tile is updated accordingly.
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

## Callback for when the request to the server for favoriting or unfavoriting the package is completed.
func on_request_completed_faving_package(_result, response_code, _headers, _body):
	if response_code != 200:
		return
	
	# could be handled through a response instead if server provides it in the future
	asset_handler.server_handler.fetch_package_faves(
		asset_handler.category_handler.get_currently_open_category(),
		asset_info.package_name,
		self
		)

## Sets the highlighted state of the tile, used to indicate if the tile is currently clicked or not
func set_highlighted(is_highlighted: bool) -> void:
	tile_sub_logic.set_highlighted(is_highlighted)

## Callback for when the tile is clicked, sets the currently clicked asset in the asset handler to this tile
func _on_asset_clicked_button_pressed() -> void:
	tile_sub_logic.set_highlighted(true)
	asset_handler.asset_clicked(self)

## Callback for when the selection checkbox of the tile is pressed.
## Adds or removes the tile from the selection depending on whether the checkbox is already pressed or not.
## Used to keep track of which assets are currently selected for upload or download in the explorer.
func _on_selection_checkbox_pressed() -> void:
	if is_selected():
		asset_handler.server_handler.server_exchange_manager.add_to_selection(self)
	else:
		asset_handler.server_handler.server_exchange_manager.remove_from_selection(self)

## Undoes the highlighted state of the tile, used to indicate that the tile is not clicked anymore
func remove_is_clicked_highlight() -> void:
	tile_sub_logic.set_higlighted(false)

## Returns if the tile is currently selected for download
func is_selected() -> bool:
	return tile_sub_logic.selected.button_pressed

## Returns the [TileSubLogic] instance, containing state information
func get_tile_sublogic() -> TileSubLogic:
	return tile_sub_logic

## Returns [AssetInfo] instance, containing information about the represented asset
func get_asset_info() -> AssetInfo:
	return asset_info

## Callbacks for the favorite button, used to favorite or unfavorite the package represented by the tile.
## Initiates a request to the server to favorite or unfavorite the package depending on its current state.
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

## Returns the preview image of the asset
func get_preview_image() -> Image:
	return preview_image
