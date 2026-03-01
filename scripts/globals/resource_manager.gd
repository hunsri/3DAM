extends Node

var ASSET_VIEW_2D_LINE = preload("uid://dg77jbtit2go")
var LOCATION_BUTTON_GROUP = preload("uid://mu8a2ehudi1e")
const COMMENT = preload("uid://dtqmjtp846oyo")

func create_tile_line():
	var tile_line = ASSET_VIEW_2D_LINE.instantiate()
	return tile_line

func create_comment(comment_author: String, comment_text: String) -> Control:
	var comment: Control = COMMENT.instantiate()
	var ret: Comment = comment
	ret.setup(comment_author, comment_text)
	return ret
