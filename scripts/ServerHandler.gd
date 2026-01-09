class_name ServerHandler extends Node

# making basic fetches through REST?
var ws: WebSocketPeer = WebSocketPeer.new()
const WS_PRE = "ws://"
const HTTP_PRE = "http://"

var address = "127.0.0.1:8000"
var server_name: String

func _ready():
	pass
	#_fetch_server_info()
	#ws.inbound_buffer_size = 20 * 1024 * 1024
	#
	#if ws.connect_to_url(WS_PRE+address) != OK:
		#printerr("WS connect failed")
		#return

func _fetch_server_info():
	var request_address = HTTP_PRE+address+"/info"
	print(request_address)
	
	%HTTPRequest.request_completed.connect(_on_request_completed)
	%HTTPRequest.request(request_address)

func _on_request_completed(_result, _response_code, _headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	
	print(json["server_name"])
	print(json["server_version"])
	print(json["categories"])
