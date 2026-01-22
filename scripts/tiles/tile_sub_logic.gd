extends PanelContainer

@export var selected: CheckBox
@export var selected_status_bar: Node
@export var downloaded_status_bar: Node

var _is_asset = false

enum TileStatus {
	NONE,
	DEFAULT,
	SELECTED,
	DOWNLOADED,
}
var tile_status: TileStatus = TileStatus.DEFAULT

func _ready():
	if _is_asset:
		change_status(tile_status)
	else:
		change_status(TileStatus.NONE) 

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
			

func _on_check_box_pressed() -> void:
	if selected.button_pressed:
		change_status(TileStatus.SELECTED)
	else:
		change_status(TileStatus.DEFAULT)
