## Represents a locally stored asset as a 2Dimensional tile in the AssetExplorerView.
##
## Can represent both local assets and packages.
## For server assets, see [ServerAssetTile2D].
class_name AssetTile2D extends AbstractAssetTile

@export var asset_name_label: Label		## the label that displays the name of the asset
@export var spawn_point: Node3D			## insertion point for the 3D model in the [member sub_viewport]
@export var tile_sub_logic: TileSubLogic ## contains state information about the tile, such as whether it's highlighted or selected
@export var sub_viewport: SubViewport	## used to display the preview of the asset in the tile

var asset_handler: AssetExplorerHandler	## used to access instances of related handlers and to communicate if the tile is interacted with
var asset_info: AssetInfo				## contains information about the represented asset
var package_info: PackageInfo = null 	## only present if asset_tile is a package
var asset_info_of_current_package_version: AssetInfo = null ## only present if asset_tile is a package


## on ready, we check whether the asset is a package or a 3D model.[br][br]
## If it's a 3D model, we display the preview of the model.
## If it's a package, we display the preview of the model of the latest available package version
## and set the file extension of the tile to that of the model asset of the latest available package version.
func _ready() -> void:
	
	if asset_info.asset_type == AssetInfo.AssetType.MODEL_3D:
		display_model_preview()
		tile_sub_logic.set_is_package(false)
		tile_sub_logic.is_local = true
		tile_sub_logic.set_file_extension(asset_info.asset_file_name.get_extension())
	if asset_info.asset_type == AssetInfo.AssetType.ASSET_PACKAGE:
		display_package_preview()
		tile_sub_logic.set_is_package(true)
		
		var package_path = asset_info.get_path_to_local_asset()
		var package_version = PackageUtils.get_latest_available_package_version(package_path, false)
		asset_info_of_current_package_version = PackageUtils.load_package_version_asset_info_from_root(package_path, package_version)
		
		if asset_info_of_current_package_version != null:
			tile_sub_logic.set_file_extension(asset_info_of_current_package_version.asset_file_name.get_extension())

## Sets up the tile with the given asset info and asset handler.
## Also checks whether the asset is a package or a 3D model and sets the tile up accordingly.[br][br]
## [color=blue]Note:[/color] This function needs to be called after instantiating the tile and before adding it to the view,
## otherwise the tile won't be set up correctly.		
func setup_tile(p_asset_handler: AbstractExplorerHandler, p_asset_info: AssetInfo):
	
	asset_info = p_asset_info
	
	set_handler(p_asset_handler)
	set_asset_label(p_asset_info.asset_file_name)
	
	if asset_info.asset_type == AssetInfo.AssetType.ASSET_PACKAGE:
		package_info = PackageUtils.load_package_info_from_root(asset_info.get_path_to_local_asset())
	
	var is_supported = AssetUtils.is_file_name_supported(p_asset_info.asset_file_name)
	is_supported = is_supported || PackageUtils.is_target_package(asset_info.get_path_to_local_asset())
	tile_sub_logic.set_is_supported_asset(is_supported)
	
	# disable selection for exchange if no server is present in the view
	if asset_handler.server_handler == null:
		tile_sub_logic.set_selection_disabled(true)

## Creates an image for usage as a preview inside a package
func get_preview_image() -> Image:
	return sub_viewport.get_texture().get_image()

## Sets the asset handler for this tile, which is used to access instances of related handlers
func set_handler(p_asset_handler: AssetExplorerHandler) -> void:
	asset_handler = p_asset_handler

## Sets the asset label of the tile to the given asset name
func set_asset_label(asset_name: String):
	asset_name_label.text = asset_name

## Sets the highlighted state of the tile, used to indicate if the tile is currently clicked or not
func set_highlighted(is_highlighted: bool) -> void:
	tile_sub_logic.set_highlighted(is_highlighted)

## Callback for when the tile is clicked, sets the currently clicked asset in the asset handler to this tile	
func _on_asset_clicked_button_pressed() -> void:
	asset_handler.asset_clicked(self)
	tile_sub_logic.set_highlighted(true)

## Creates a preview of the asset if it's a 3D model for display in the tile.
## The model is rendered for one frame in a sub viewport and displayed as a texture in the tile.
func display_model_preview() -> void:
	var full_path = asset_handler.directory_handler.get_currently_open_directory() + "/" + asset_name_label.text
	ModelLoader.load_attach_model(full_path, spawn_point)

## similar to [method display_model_preview], but for packages.
##Displays the model of the latest available package version as a preview in the tile.
func display_package_preview() -> void:
	
	if package_info == null:
		return
	
	var asset_path = PackageUtils.get_latest_available_package_version(asset_info.get_path_to_local_asset(), true)

	var model_asset_path := PackageUtils.get_path_to_model_asset(asset_path)
	
	ModelLoader.load_attach_model(model_asset_path, spawn_point)

## Callback for when the selection checkbox of the tile is pressed.
## Adds or removes the tile from the selection depending on whether the checkbox is already pressed or not.
## Used to keep track of which assets are currently selected for upload or download in the explorer.
func _on_selection_checkbox_pressed() -> void:
	if is_selected():
		asset_handler.server_handler.server_exchange_manager.add_to_selection(self)
	else:
		asset_handler.server_handler.server_exchange_manager.remove_from_selection(self)

## Returns if the tile is currently selected
func is_selected() -> bool:
	return tile_sub_logic.selected.button_pressed

## Returns the tile sub logic of the tile, which contains information about the state of the tile
func get_tile_sublogic() -> TileSubLogic:
	return tile_sub_logic

## Returns the asset info of the tile, containing information about the represented asset
func get_asset_info() -> AssetInfo:
	return asset_info

## Callback for when the favorite button of the tile is pressed.[br][br]
## [color=yellow]Warning:[/color] This is for future implementation of favoriting local assets, currently it doesn't do anything.
func _on_fave_button_pressed() -> void:
	# For future implementation of favoriting local assets
	if tile_sub_logic.is_faved:
		pass
	else:
		pass
