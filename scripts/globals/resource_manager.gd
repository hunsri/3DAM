extends Node

var ASSET_VIEW_2D_LINE = preload("uid://dg77jbtit2go")
var LOCATION_BUTTON_GROUP = preload("uid://mu8a2ehudi1e")
const COMMENT = preload("uid://dtqmjtp846oyo")
const LOCATION_BUTTON = preload("uid://cbkbgf8jlopto")

func create_tile_line():
	var tile_line = ASSET_VIEW_2D_LINE.instantiate()
	return tile_line

func create_comment(comment_data: Comment.CommentData, asset_sidebar_handler: AssetSidebarHandler) -> Control:
	var comment: Control = COMMENT.instantiate()
	var ret: Comment = comment
	ret.setup(comment_data, asset_sidebar_handler)
	return ret

func create_server_button(server_address: String, server_name: String, newly_added: bool = false) -> Control:
	var location_button: Control = LOCATION_BUTTON.instantiate()
	var ret: Location_Handler = location_button
	ret.setup(Location_Handler.SceneType.Server, server_address, server_name, newly_added)
	return ret
