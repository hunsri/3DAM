class_name CompareManager extends Node

@onready var details_view_manager: DetailsViewManager = $TabContainer/Details
@onready var compare_3d_view_manager: Compare3DViewManager = $"TabContainer/3D"
@onready var compare_2d_view_manager: Compare2DViewManager = $"TabContainer/2D"

@onready var loading_message: PanelContainer = $LoadingMessage
@onready var tab_container: TabContainer = $TabContainer

@onready var undo_button: Button = $MarginContainer/HBoxContainer/undo
@onready var redo_button: Button = $MarginContainer/HBoxContainer/redo

var compare_models: Array[AbstractAssetTile]

var undo_stack: Array[CompareActionCommand]
var redo_stack: Array[CompareActionCommand]

func _ready() -> void:	
	pre_ignite_tabs()
	undo_button.pressed.connect(_undo)
	redo_button.pressed.connect(_redo)
	
func _process(_delta: float) -> void:
	undo_button.disabled = undo_stack.size() < 1
	redo_button.disabled = redo_stack.size() < 1

func remove_model(index: int, is_do_command: bool = false) -> void:
	if !is_do_command:
		undo_stack.append(CompareActionCommand.new(self, CompareActionCommand.COMMAND_TYPE.REMOVE, compare_models[index], index))
		redo_stack.clear()
	
	details_view_manager.remove_model_compare_element(index)
	compare_3d_view_manager.remove_model_compare_element(index)
	compare_2d_view_manager.remove_model_compare_element(index)
	
	compare_models.remove_at(index)

func insert_compare_model_from_tile(tile: AbstractAssetTile, index: int = 0, is_do_command: bool = false) -> void:
	if !is_do_command:
		undo_stack.append(CompareActionCommand.new(self, CompareActionCommand.COMMAND_TYPE.INSERT, tile, index))
		redo_stack.clear()
	
	details_view_manager.create_model_compare_element(tile, index)
	compare_3d_view_manager.create_model_compare_element(tile, index)
	compare_2d_view_manager.create_model_compare_element(tile, index)
	
	compare_models.insert(index, tile)

func _undo():
	if undo_stack.size() > 0:
		redo_stack.append(undo_stack.pop_back().undo())

func _redo():
	if redo_stack.size() > 0:
		undo_stack.append(redo_stack.pop_back().redo())

## Rendering of all tabs, to force shader compilation
## This reduces loading times later on
func pre_ignite_tabs() -> void:
	await get_tree().process_frame

	for tab in tab_container.get_children():
		tab.visible = true
		await get_tree().process_frame
		tab.visible = false
	
	tab_container.get_children()[0].visible = true
	loading_message.visible = false
	
