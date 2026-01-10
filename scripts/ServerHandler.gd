class_name ServerHandler extends Node

@export var http: HTTPRequest

signal has_fetched_from_server

# making basic fetches through REST?
var ws: WebSocketPeer = WebSocketPeer.new()
const WS_PRE = "ws://"
const HTTP_PRE = "http://"

var address = "127.0.0.1:8000"
var server_name: String
var server_version: String
var asset_categories: Array

var has_fetched_data: bool = false

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
	
	http.request(request_address)
	http.request_completed.connect(_on_request_completed)
	http.request(request_address)

func _on_request_completed(_result, _response_code, _headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	
	server_name = json["server_name"]
	server_version = json["server_version"]
	asset_categories = json["categories"]
	
	#print(json["server_name"])
	#print(json["server_version"])
	#print(json["categories"])
	
	emit_signal("has_fetched_from_server")
	has_fetched_data = true

func get_asset_category() -> Array:
	return asset_categories

func get_server_name() -> String:
	return server_name

# TODO fix potential race condition when requesting data
# this helper function isn't working, but we will need something like this!
#func waiting_for_data() -> void:
#	while not has_fetched_data:
#		await has_fetched_from_server
