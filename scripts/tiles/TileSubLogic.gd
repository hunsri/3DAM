class_name TileSubLogic extends PanelContainer

@export var selected: CheckBox
@export var selected_status_bar: Node
@export var downloaded_status_bar: Node

@export var package_indicator: TextureRect
@export var extension_indicator: Label
@export var extension_indicator_color: ColorRect

var _is_supported_asset = false
var selection_disabled = false
var _is_package = false

var asset_file_extension_types: Dictionary[String, Color] = {
	"GLB": Color("#437c24"), # color taken from https://www.khronos.org/gltf/
	"glTF": Color("#437c24"),
	"OBJ": Color.DARK_ORANGE,
	"FBX": Color.DEEP_SKY_BLUE,
	"STL": Color.SILVER,
	"PLY": Color.DIM_GRAY,
	"DAE": Color("#f1a42b"), # from https://www.khronos.org/collada/
	"USD": Color("#7dd1f6"), # from https://www.pixar.com/openusd
	"USDC": Color("#7dd1f6"),
	"USDZ": Color("#7dd1f6"),
	"STEP": Color.CORAL
}

enum TileStatus {
	NONE,
	DEFAULT,
	SELECTED,
	DOWNLOADED,
}
var tile_status: TileStatus = TileStatus.NONE

func _ready():
	reload()

func reload():
	if _is_supported_asset && !selection_disabled:
		change_status(TileStatus.DEFAULT)
	else:
		change_status(TileStatus.NONE)
	
	if _is_package:
		package_indicator.visible = true
	else:
		package_indicator.visible = false
	
	

func change_status(status: TileStatus) -> void:
	tile_status = status
	
	match status:
		TileStatus.NONE:
			selected.visible = false
			selected.button_pressed = false
			selected_status_bar.visible = false
			downloaded_status_bar.visible = false
		TileStatus.DEFAULT:
			selected.visible = true
			selected.button_pressed = false
			selected.disabled = false
			selected_status_bar.visible = false
			downloaded_status_bar.visible = false
		TileStatus.SELECTED:
			selected.visible = true
			selected.button_pressed = true
			selected.disabled = false
			selected_status_bar.visible = true
			downloaded_status_bar.visible = false
		TileStatus.DOWNLOADED:
			selected.visible = true
			selected.button_pressed = true
			selected.disabled = true
			selected_status_bar.visible = false
			downloaded_status_bar.visible = true
			

func set_selection_disabled(p_selection_disabled: bool) -> void:
	selection_disabled = p_selection_disabled
	reload()

func set_is_supported_asset(is_supported: bool) -> void:
	_is_supported_asset = is_supported
	reload()

func set_is_package(is_package: bool) -> void:
	_is_package = is_package
	reload()
	
func _on_check_box_pressed() -> void:
	if selected.button_pressed:
		change_status(TileStatus.SELECTED)
	else:
		change_status(TileStatus.DEFAULT)

func set_file_extension(extension: String) -> void:
	
	if extension == "":
		extension_indicator.visible = false
		return
	
	extension = extension.to_upper()
	if extension.to_upper() == "GLTF":
		extension = "glTF" # match special writing
	
	extension_indicator.text = extension
	
	if asset_file_extension_types.has(extension):
		extension_indicator_color.color = asset_file_extension_types.get(extension)
		extension_indicator.visible = true
	else:
		extension_indicator.visible = false
