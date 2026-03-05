class_name Request extends Node

# modified error handling
# template from https://gist.github.com/Bujupah/3badf38027cb79a3cc19077ca6b7dd30
# Many thanks!

var http_request: HTTPRequest
var request_completed: bool = false
var response_data: Dictionary = {}
var response_error: int = OK

func _init():
	# Initialize the HTTPRequest node
	http_request = HTTPRequest.new()
	http_request.timeout = 1.0
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)

func _on_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	# Set the response data and mark the request as completed
	var response  = JSON.parse_string(body.get_string_from_utf8())
	if response == null:
		response_data = {}
	else:
		response_data = response
	
	response_error = _result
	request_completed = true

func _http_get(url: String, headers: Array[String] = []) -> Array:
	# Reset the completion flag and response data
	request_completed = false
	response_data = {}
	response_error = OK

	# Make an HTTP GET request
	var error = http_request.request(url, headers, HTTPClient.METHOD_GET)
	if error != OK:
		#print("Error making GET request: %s" % error)
		return [{"error": error}, error]

	# Wait for the request to complete
	while not request_completed:
		# Yield to the idle frame to allow other processing
		await get_tree().process_frame

	return [response_data, response_error]

func _http_post(url: String, body: Dictionary = {}, headers: Array[String] = []) -> Array:
	# Reset the completion flag and response data
	request_completed = false
	response_data = {}
	response_error = OK

	# Make an HTTP POST request
	var json_body = JSON.stringify(body)
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, json_body)
	if error != OK:
		#print("Error making POST request: %s" % error)
		return [{"error": error}, error]

	# Wait for the request to complete
	while not request_completed:
		# Yield to the idle frame to allow other processing
		await get_tree().idle_frame

	return [response_data, response_error]
	
static func http_get(node: Node, url: String, headers: Array[String] = []) -> Array:
	var req = new()
	node.add_child(req)
	var get_result = await req._http_get(url, headers)
	req.queue_free()
	return get_result

static func http_post(node: Node, url: String, body: Dictionary = {}, headers: Array[String] = []) -> Array:
	var req = new()
	node.add_child(req)
	var get_result = await req._http_post(url, body, headers)
	req.queue_free()
	return get_result
