class_name AssetMetaInfoDisplay extends Node

@export var comment_spawner: VBoxContainer
@export var comment_section: FoldableContainer
@export var _is_local: bool

# set from parent
var asset_info_handler: AssetInfoHandler

func _ready() -> void:
	# comment section is only available on servers
	if _is_local:
		comment_section.visible = false
	else:
		comment_section.visible = true

func add_comment(comment_data: Comment.CommentData) -> void:
	comment_spawner.add_child(ResourceManager.create_comment(comment_data, asset_info_handler))

func clear_comments() -> void:
	for child in comment_spawner.get_children():
		child.queue_free()

## called when new data from server gets fetched
func on_request_completed_fetch_package_comments(_result, _response_code, _headers, body):

	clear_comments()
	
	var json_string: String = body.get_string_from_utf8()
	var json = JSON.parse_string(json_string)
	if json == null:
		return
	
	var comment_count = json["comments"].size()
	
	for i in comment_count:
		var comment_data := Comment.CommentData.new(
			json["comments"][i]["message_uuid"],
			json["comments"][i]["comment_text"],
			json["comments"][i]["timestamp"],
			json["comments"][i]["is_user_comment"],
		)
		add_comment(comment_data)

func on_request_completed_delete_package_comment(_result, _response_code, _headers, _body) -> void:	
	if _response_code != 200:
		return
	
	# not ideal, but requesting a new comment list makes it easy to see if the comment was deleted
	var explorer_handler :=  asset_info_handler.server_handler.server_exchange_manager.server_explorer_handler
	var category_name = explorer_handler.category_handler.get_currently_open_category()
	var package_name = explorer_handler.latest_clicked_server_tile.asset_info.package_name
	asset_info_handler.server_handler.fetch_package_comments(category_name, package_name, self)
