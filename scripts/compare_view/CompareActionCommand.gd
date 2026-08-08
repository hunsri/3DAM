class_name CompareActionCommand extends Node

enum COMMAND_TYPE {INSERT, REMOVE} 
var type: COMMAND_TYPE

var tile: AbstractAssetTile
var index: int

var compare_manager: CompareManager

func _init(p_compare_manager: CompareManager, p_type: COMMAND_TYPE, p_tile: AbstractAssetTile, p_index: int) -> void:
	compare_manager = p_compare_manager
	
	type = p_type
	tile = p_tile
	index = p_index
	
func redo() -> CompareActionCommand:
	match type:
		COMMAND_TYPE.INSERT:
			compare_manager.insert_compare_model_from_tile(tile, index, true)
		COMMAND_TYPE.REMOVE:
			compare_manager.remove_model(index, true)
			
	return self

func undo() -> CompareActionCommand:
	match type:
		COMMAND_TYPE.INSERT:
			compare_manager.remove_model(index, true)
		COMMAND_TYPE.REMOVE:
			compare_manager.insert_compare_model_from_tile(tile, index, true)

	return self
