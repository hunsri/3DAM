class_name ServerHandler extends Node

#@export var http: HTTPRequest

signal has_fetched_from_server

var ws: WebSocketPeer = WebSocketPeer.new()
const WS_PRE = "ws://"
const HTTP_PRE = "http://"

var address = "127.0.0.1:8000"
var server_name: String
var server_version: String
var asset_categories: Array

var has_fetched_data: bool = false

var _current_category_assets_names: Array #not optimal to store it after each call, but will do for now

func _ready():
	_fetch_server_info()
	#ws.inbound_buffer_size = 20 * 1024 * 1024
	#
	#if ws.connect_to_url(WS_PRE+address) != OK:
		#printerr("WS connect failed")
		#return

func _fetch_server_info():
	var request_address = HTTP_PRE+address+"/info"
	print(request_address)
	
	var http = _create_http_request_node()
	
	http.request(request_address)
	http.request_completed.connect(_on_request_completed_server_info)
	http.request(request_address)
	
	_cleanup_http_request_node(http)

func _on_request_completed_server_info(_result, _response_code, _headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	
	server_name = json["server_name"]
	server_version = json["server_version"]
	asset_categories = json["categories"]
	
	emit_signal("has_fetched_from_server")
	has_fetched_data = true

func _fetch_asset_names_in_category(category_name: String):
	#var ret:Array = []
	
	var sub_url = "/assets/categories/"+category_name+"/assets_list"
	var request_address = HTTP_PRE+address+sub_url
	
	var http = _create_http_request_node()
	
	http.request(request_address)
	http.request_completed.connect(_on_request_completed_asset_names_in_category)
	
	_cleanup_http_request_node(http)
	return _current_category_assets_names

func _on_request_completed_asset_names_in_category(_result, _response_code, _headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	
	_current_category_assets_names = json["assets"]
	
func get_asset_category() -> Array:
	return asset_categories

func get_server_name() -> String:
	return server_name


func _create_http_request_node() -> HTTPRequest:
	var http_request = HTTPRequest.new()
	
	self.add_child(http_request)
	return http_request

func _cleanup_http_request_node(http_request: HTTPRequest) -> void:
	await http_request.request_completed
	
	http_request.queue_free()
	http_request = null

# TODO fix potential race condition when requesting data
# this helper function isn't working, but we will need something like this!
#func waiting_for_data() -> void:
#	while not has_fetched_data:
#		await has_fetched_from_server
