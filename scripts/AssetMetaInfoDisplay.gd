class_name AssetMetaInfoDisplay extends Node

@export var comment_spawner: VBoxContainer
@export var comment_section: FoldableContainer
var _is_local: bool = true

@export var comment_text_edit: TextEdit

# set from parent
var asset_sidebar_handler: AssetSidebarHandler

func _ready() -> void:
	set_is_local_asset(_is_local)
	
func set_is_local_asset(is_local: bool) -> void:
	_is_local = is_local
	
	# comment section is only available on servers
	if _is_local:
		comment_section.visible = false
	else:
		comment_section.visible = true

func add_comment(comment_data: Comment.CommentData) -> void:
	comment_spawner.add_child(ResourceManager.create_comment(comment_data, asset_sidebar_handler))

func clear_comments() -> void:
	for child in comment_spawner.get_children():
		child.queue_free()

## called when new data from server gets fetched
func on_request_completed_fetch_package_comments(_result, _response_code, _headers, body):

	clear_comments()
	
	var json_string: String = body.get_string_from_utf8()
	var result = JSON.parse_string(json_string)
	if result == null:
		return
	
	var json: Dictionary = result
	if not json.has("comments"):
		return
	
	var comment_count = json["comments"].size()
	
	for i in comment_count:
		var index = comment_count-i-1 #reversing array traversion
		
		var comment_data := Comment.CommentData.new(
			json["comments"][index]["message_uuid"],
			json["comments"][index]["comment_text"],
			json["comments"][index]["timestamp"],
			json["comments"][index]["is_user_comment"],
		)
		add_comment(comment_data)

func on_request_completed_delete_package_comment(_result, _response_code, _headers, _body) -> void:	
	if _response_code != 200:
		return
	
	# not ideal, but requesting a new comment list makes it easy to see if the comment was deleted
	var explorer_handler :=  asset_sidebar_handler.server_handler.server_exchange_manager.server_explorer_handler
	var category_name = explorer_handler.category_handler.get_currently_open_category()
	var package_name = explorer_handler.asset_sidebar_handler.get_latest_clicked_asset().asset_info.package_name
	asset_sidebar_handler.server_handler.fetch_package_comments(category_name, package_name, self)

func _on_send_button_pressed() -> void:
	asset_sidebar_handler.server_handler.post_package_comment(comment_text_edit.text)

func on_request_completed_post_package_comment(_result, _response_code, _headers, _body) -> void:	
	if _response_code != 200:
		return
	
	comment_text_edit.clear()
	
	var explorer_handler :=  asset_sidebar_handler.server_handler.server_exchange_manager.server_explorer_handler
	var category_name = explorer_handler.category_handler.get_currently_open_category()
	var package_name = explorer_handler.asset_sidebar_handler.get_latest_clicked_asset().asset_info.package_name
	asset_sidebar_handler.server_handler.fetch_package_comments(category_name, package_name, self)
