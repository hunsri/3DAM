class_name AddServerManager extends Node

@export var server_connection_checker: ServerConnectionChecker
@export var address_field: TextEdit
@export var status_field: TextEdit

const WARN_FONT_COLOR: Color = Color(1.0,0.47,0.41,1)
const DEFAULT_FONT_COLOR: Color = Color(0.87,0.87,0.87,1)

var location_selector: LocationSelector

func setup(p_location_selector: LocationSelector) -> void:
	location_selector = p_location_selector

func _on_add_server_button_pressed() -> void:
	address_field.text = address_field.text.strip_edges()
	
	status_field.add_theme_color_override("font_readonly_color", DEFAULT_FONT_COLOR)
	status_field.text = "CHECKING CONNECTION..."
	
	var result := await server_connection_checker.check_server_connection(address_field.text)
	
	if result == {}:
		_display_error()
		return
	
	if server_connection_checker.is_response_data_valid(result):
		
		var server_name = ""
		
		if result.has("server_name"):
			server_name = result["server_name"]
		
		status_field.text = "Server connection established!\n\nAdded new server:\n"+server_name
		location_selector.add_server(address_field.text, server_name, true)

func _display_error() -> void:
	status_field.add_theme_color_override("font_readonly_color", WARN_FONT_COLOR) 
	status_field.text = "UNABLE TO CONNECT TO SERVER!\nIs the entered address correct?"
