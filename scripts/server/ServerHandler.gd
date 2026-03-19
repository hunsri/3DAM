## A class to initiate communication with an asset server
##
## Handles the communication between client and server and relays information
## to the ServerExchangeManager, which then relays it to the correct handlers.
class_name ServerHandler extends Node

## Stores the server address
@export var server_info: ServerInfo
## Reference to the ServerExchangeManager to relay information to it
@export var server_exchange_manager: ServerExchangeManager

## Fired when the server information have been successfully fetched
signal has_fetched_from_server
## Fired when all package names in a category have been successfully fetched. The signal carries the list of package names as an argument.
signal has_fetched_names_in_category

const HTTP_PRE = "http://"

## Name of the connected server, fetched from the server on scene load
var server_name: String
## Version of the connected server, fetched from the server on scene load
var server_version: String
## List of asset categories available on the server, fetched from the server on scene load
var asset_categories: Array

## Indicates whether the server information have been fetched from the server
var has_fetched_data: bool = false

## Requests the basic information about the server on scene load
func _ready():
	_fetch_server_info()
	server_exchange_manager.set_server_handler(self)

## Requests the basic information about the server, such as
## server name, version and available asset categories.
func _fetch_server_info():
	var request_address = HTTP_PRE+server_info.address+"/info"
	var http = _create_http_request_node()
	
	http.request(request_address)
	http.request_completed.connect(_on_request_completed_server_info)
	
	_cleanup_http_request_node(http)

## Handles the received server information [br]
## [color=yellow]Warning:[/color] Should only be called within _fetch_server_info
func _on_request_completed_server_info(_result, _response_code, _headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	
	server_name = json["server_name"]
	server_version = json["server_version"]
	asset_categories = json["categories"]
	
	emit_signal("has_fetched_from_server")
	has_fetched_data = true

## Requests the list of all package names in a given category from the server.
func fetch_package_names_in_category(category_name: String):
	
	var sub_url = "/assets/categories/"+category_name+"/package_list"
	var request_address = HTTP_PRE+server_info.address+sub_url
	
	var http = _create_http_request_node()
	
	http.request(request_address)
	http.request_completed.connect(_on_request_completed_package_names_in_category)
	
	_cleanup_http_request_node(http)

## Handles the received list of package names in a category [br]
## [color=yellow]Warning:[/color] Should only be called within fetch_package_names_in_category
func _on_request_completed_package_names_in_category(_result, _response_code, _headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	
	# connects to ServerExplorerHandler on_fetch_assets_info
	# not the cleanest connection, but it works
	has_fetched_names_in_category.emit(json["packages"])

## Requests the asset info for a given package from the server.
## The asset info is then used to fill the provided ServerAssetTile2D with the correct information.
func fetch_asset_info(category_name: String, package_name: String, tile: ServerAssetTile2D):
	var sub_url = "/assets/categories/"+category_name+"/"+package_name+"/asset_info"
	var request_address = HTTP_PRE+server_info.address+sub_url
	
	var http = _create_http_request_node()
	http.request(request_address)
	http.request_completed.connect(tile.on_request_completed_fetch_asset_info)
	
	_cleanup_http_request_node(http)

## Prepares the local package structure for the incoming asset by requesting the package info from the server.
## After building the structure, the asset archive is requested through download_asset_from_server.
func download_package_info_for_saving(category_name: String, package_name: String):
	var sub_url = "/assets/categories/"+category_name+"/"+package_name+"/package_info"
	var request_address = HTTP_PRE+server_info.address+sub_url
	
	var http = _create_http_request_node()
	http.request(request_address)
	http.request_completed.connect(server_exchange_manager.on_request_completed_download_package_info_for_saving)
	
	_cleanup_http_request_node(http)

## Requests the asset preview image for a given package from the server.
## The received image is then set as the preview image of the provided ServerAssetTile2D.
func fetch_asset_preview(category_name: String, package_name: String, tile: ServerAssetTile2D):
	var sub_url = "/assets/categories/"+category_name+"/"+package_name+"/preview"
	var request_address = HTTP_PRE+server_info.address+sub_url
	
	var http = _create_http_request_node()
	
	http.request(request_address)
	http.request_completed.connect(tile.on_request_completed_fetch_asset_preview)
	
	_cleanup_http_request_node(http)

## Requests the asset archive for a given package from the server. The archive is then extracted and the asset is saved locally.
func download_asset_from_server(category_name: String, package_name: String):
	var sub_url = "/assets/categories/"+category_name+"/"+package_name+"/download"
	var request_address = HTTP_PRE+server_info.address+sub_url
	
	var http = _create_http_request_node()
	
	http.request(request_address)
	
	http.request_completed.connect(server_exchange_manager.on_request_completed_download_asset_from_server)
	
	_cleanup_http_request_node(http)

## Getter for all the servers asset categories
func get_asset_category() -> Array:
	return asset_categories

## Getter for the server name
func get_server_name() -> String:
	return server_name

## Entry point for uploading an asset to the server. First the asset info is uploaded, then the archive and then the preview image.
## In this first step the asset info is uploaded, which prepares the server for the following incoming asset.
## Uploads asset info. The archive and preview are uploaded via callbacks after server confirmation.
func upload_asset_info(category_name: String, asset_info: AssetInfo):
	
	var sub_url = "/assets/categories/"+category_name+"/upload_asset_info"
	var request_address = HTTP_PRE+server_info.address+sub_url
	var headers = ["Content-Type: application/json"]
	
	var http = _create_http_request_node()
	
	var json_body:String = JSON.stringify(asset_info.to_dict())
	
	var error = http.request(
		request_address,
		headers,
		HTTPClient.METHOD_POST,
		json_body
	)
	
	if error != OK:
		print("Request error:", error)
	
	http.request_completed.connect(server_exchange_manager.on_request_completed_upload_asset_info)
	
	_cleanup_http_request_node(http)

## Follow up step from upload_asset_info. Uploads the asset archive to the server after the asset info has been successfully uploaded. [br][br]
## [color=yellow]Warning:[/color] Shouldn't be called outside of the upload process
func upload_asset_archive_to_server(category_name: String, package_name: String, version: String, asset_archive_path: String):
	
	var sub_url = "/assets/categories/"+category_name+"/"+package_name+"/"+version+"/upload_asset_archive"
	var request_address = HTTP_PRE+server_info.address+sub_url
	
	var http = _create_http_request_node()
	
	var file: FileAccess = null
	
	file = FileAccess.open(asset_archive_path, FileAccess.READ)
	if file == null:
		return {"success": false, "status_code": 0, "body": "Failed to open file"}
	var data: PackedByteArray = file.get_buffer(file.get_length())
	file.close()
	
	var body: Array = []
	for b in data:
		body.append(b)
	
	var headers: Array = ["Content-Type: application/zip", "Content-Length: %d" % data.size()]
	
	var error = http.request_raw(
		request_address,
		headers,
		HTTPClient.METHOD_POST,
		body)
	
	if error != OK:
		print("Request error:", error)
	
	http.request_completed.connect(server_exchange_manager.on_request_completed_upload_asset_archive_to_server)
	
	_cleanup_http_request_node(http)

## Follow up step from upload_asset_archive_to_server.
## Uploads the asset preview image to the server after the asset archive has been successfully uploaded. [br][br]
## [color=yellow]Warning:[/color] Shouldn't be called outside of the upload process
func upload_asset_preview_image(category_name: String, package_name: String, version: String, image: Image):
	
	var sub_url = "/assets/categories/"+category_name+"/"+package_name+"/"+version+"/upload_asset_preview"
	var request_address = HTTP_PRE+server_info.address+sub_url
	
	var http = _create_http_request_node()
	
	var png_bytes : PackedByteArray = image.save_png_to_buffer()
	
	var body: Array = []
	for b in png_bytes:
		body.append(b)
	
	var headers: Array = ["Content-Type: image/png", "Content-Length: %d" % png_bytes.size()]
	
	var error = http.request_raw(
		request_address,
		headers,
		HTTPClient.METHOD_POST,
		body)
	
	if error != OK:
		print("Request error:", error)
	
	http.request_completed.connect(server_exchange_manager.on_request_completed_upload_asset_preview_image)
	
	_cleanup_http_request_node(http)

## Sends a request to the server to add a package to the users favorites. The server then adds the user
## to the list of users who have favorited the package. [br] [br]
## Also connects the request completion to the asset tile's on_request_completed_faving_package, 
## which connects to fetch_package_faves to update the asset tile's UI.
func fave_package(category_name: String, package_name: String, asset_tile: ServerAssetTile2D):
	
	var sub_url = "/assets/categories/"+category_name+"/"+package_name+"/"+"add_favorite"
	var request_address = HTTP_PRE+server_info.address+sub_url
	var headers = ["Content-Type: application/json"]
	
	var http = _create_http_request_node()
	
	var body := "{\"user_uuid\": \""+ Startup.load_identity_uuid()+"\"}"
	
	var error = http.request(
		request_address,
		headers,
		HTTPClient.METHOD_PATCH,
		body
	)
	
	if error != OK:
		print("Request error:", error)
	
	http.request_completed.connect(asset_tile.on_request_completed_faving_package)
	_cleanup_http_request_node(http)

## Sends a request to the server to remove a package from the users favorites.
## The server then removes the user from the list of users who have favorited the package.[br][br]
## Also connects the request completion to the asset tile's on_request_completed_faving_package,[br]
## which connects to fetch_package_faves to update the asset tile's UI.
func unfave_package(category_name: String, package_name: String, asset_tile: ServerAssetTile2D):
	var sub_url = "/assets/categories/"+category_name+"/"+package_name+"/"+"remove_favorite"
	var request_address = HTTP_PRE+server_info.address+sub_url
	var headers = ["Content-Type: application/json"]
	
	var http = _create_http_request_node()
	
	var body := "{\"user_uuid\": \""+ Startup.load_identity_uuid()+"\"}"
	
	var error = http.request(
		request_address,
		headers,
		HTTPClient.METHOD_PATCH,
		body
	)
	
	if error != OK:
		print("Request error:", error)
	
	http.request_completed.connect(asset_tile.on_request_completed_faving_package)
	_cleanup_http_request_node(http)

## Follow up step from fave_package and unfave_package.
## Fetches the updated list of users who have favorited the package and updates the asset tile's UI accordingly.
## Also called when the asset tile is initially loaded or reloaded later
func fetch_package_faves(category_name: String, package_name: String, asset_tile: ServerAssetTile2D):
	var sub_url = "/assets/categories/"+category_name+"/"+package_name+"/"+"favorites"
	var query = "?user_uuid="+Startup.load_identity_uuid()
	var request_address = HTTP_PRE+server_info.address+sub_url+query
	
	var http = _create_http_request_node()
	
	var error = http.request(request_address)
	
	if error != OK:
		print("Request error:", error)
	
	http.request_completed.connect(asset_tile.on_request_completed_fetch_package_faves)
	_cleanup_http_request_node(http)

## Posts a comment to the server for a given package. Server adds comment to the package and asigns it the users UUID. [br] [br]
## Connects the request completion with the AssetMetaInfoDisplay in the sidebar, [br]
## which then triggers a fetch_package_comments to update the displayed comments.
func post_package_comment(text_message: String) -> void:
	# not optimal, but caller has no easy access to these information, so we have to do it
	var explorer_handler :=  server_exchange_manager.server_explorer_handler
	var category_name = explorer_handler.category_handler.get_currently_open_category()
	var package_name = explorer_handler.asset_sidebar_handler.get_latest_clicked_asset().asset_info.package_name
	
	var sub_url = "/assets/categories/"+category_name+"/"+package_name+"/"+"add_comment"
	var request_address = HTTP_PRE+server_info.address+sub_url
	var headers = ["Content-Type: application/json"]
	
	var http = _create_http_request_node()
	
	# ugly, but fast way for creating json payload
	var body := "{\"user_uuid\": \""+ Startup.load_identity_uuid()+"\","
	body += "\"comment_text\": \""+ text_message +"\"}"
	
	var error = http.request(
		request_address,
		headers,
		HTTPClient.METHOD_PATCH,
		body
	)
	
	http.request_completed.connect(explorer_handler.asset_sidebar_handler.asset_meta_info_display.on_request_completed_post_package_comment)
	
	if error != OK:
		print("Request error:", error)
	
	_cleanup_http_request_node(http)

## Follow up step from post_package_comment and delete_package_comment.
## Also called when the asset tile is clicked to fetch the latest comments for the package.
func fetch_package_comments(category_name: String, package_name: String, asset_info_display: AssetMetaInfoDisplay) -> void:
	var sub_url = "/assets/categories/"+category_name+"/"+package_name+"/"+"comments"
	var query = "?user_uuid="+Startup.load_identity_uuid()
	var request_address = HTTP_PRE+server_info.address+sub_url+query
	
	var http = _create_http_request_node()
	var error = http.request(request_address)
	
	if error != OK:
		print("Request error:", error)
	
	http.request_completed.connect(asset_info_display.on_request_completed_fetch_package_comments)
	
	_cleanup_http_request_node(http)

## Analogous to post_package_comment. Sends a request to the server to delete a comment with a given UUID. [br] [br]
## Connects the request completion with the AssetMetaInfoDisplay in the sidebar, [br]
## which then triggers a fetch_package_comments to update the displayed comments.
func delete_package_comment(message_uuid: String) -> void:
	# not optimal, but caller has no easy access to these information, so we have to do it
	var explorer_handler :=  server_exchange_manager.server_explorer_handler
	var category_name = explorer_handler.category_handler.get_currently_open_category()
	var package_name = explorer_handler.asset_sidebar_handler.get_latest_clicked_asset().asset_info.package_name
	
	var sub_url = "/assets/categories/"+category_name+"/"+package_name+"/"+"remove_comment"
	var request_address = HTTP_PRE+server_info.address+sub_url
	var headers = ["Content-Type: application/json"]
	
	var http = _create_http_request_node()
	
	# ugly, but fast way for creating json payload
	var body := "{\"user_uuid\": \""+ Startup.load_identity_uuid()+"\","
	body += "\"message_uuid\": \""+ message_uuid+"\"}"
	
	var error = http.request(
		request_address,
		headers,
		HTTPClient.METHOD_PATCH,
		body
	)
	
	http.request_completed.connect(explorer_handler.asset_sidebar_handler.asset_meta_info_display.on_request_completed_delete_package_comment)
	
	if error != OK:
		print("Request error:", error)
	
	_cleanup_http_request_node(http)

## Utility function to create and add an HTTPRequest node to the scene tree. Returns the created node.
## Needed for sending HTTP requests to the server [br][br]
## [color=blue]Note:[/color] After calling, _cleanup_http_request_node should be called to free the resource. [br]
## [color=yellow]Warning:[/color] Shouldn't be called from outside of this class
func _create_http_request_node() -> HTTPRequest:
	var http_request = HTTPRequest.new()
	
	self.add_child(http_request)
	return http_request

## See _create_http_request_node.[br]
## Utility function to wait for the request to complete and then free the HTTPRequest node. [br]
## [color=yellow]Warning:[/color] Shouldn't be called from outside of this class
func _cleanup_http_request_node(http_request: HTTPRequest) -> void:
	await http_request.request_completed
	
	http_request.queue_free()
	http_request = null
