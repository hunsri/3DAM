class_name Comment extends HFlowContainer

@export var comment_author_label: Label
@export var comment_text_label: Label

@export var activate_delete_button: CheckButton
@export var delete_button: Button

var _asset_sidebar_handler: AssetSidebarHandler

## data container for comments
class CommentData:
	var message_uuid: String
	var comment_text: String
	var timestamp: String
	var is_own_comment: bool
	
	func _init(p_message_uuid: String, p_comment_text: String, p_timestamp: String, p_is_own_comment: bool) -> void:
		message_uuid = p_message_uuid
		comment_text = p_comment_text
		timestamp = p_timestamp
		is_own_comment = p_is_own_comment
		
var comment_data: CommentData

func setup(p_comment_data: CommentData, p_asset_sidebar_handler: AssetSidebarHandler) -> void:
	comment_data = p_comment_data
	_asset_sidebar_handler = p_asset_sidebar_handler
	
	comment_text_label.text = comment_data.comment_text
	
	if comment_data.is_own_comment:
		comment_author_label.text = "Me"
		activate_delete_button.visible = true
		delete_button.visible = true
	else:
		comment_author_label.text = "Anon"
		activate_delete_button.visible = false
		delete_button.visible = false

## for activating the delete button, to allow deletion of the comment
func _on_activate_delete_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		delete_button.disabled = false
	else:
		delete_button.disabled = true

func _on_delete_button_pressed() -> void:
	_asset_sidebar_handler.server_handler.delete_package_comment(comment_data.message_uuid)
	
