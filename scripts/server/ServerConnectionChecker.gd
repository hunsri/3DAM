class_name ServerConnectionChecker extends Node

const HTTP_PRE = "http://"

func check_server_connection(address: String) -> Dictionary:
	var request_address = HTTP_PRE+address+"/info"
	
	var res = await Request.http_get(self, request_address)
	var data = res[0]
	var err = res[1]
	
	if err != OK:
		return {}

	return data
	
func is_response_data_valid(data: Dictionary) -> bool:
	if not data.has("server_version"):
		return false
	if not data.has("categories"):
		return false
	
	return true
