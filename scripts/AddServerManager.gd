## Manages the process of adding a new asset-server
##
## To be added to the [code]AddServerUI[/code] scene.
## The manager handles the process of checking if the provided server address can be connected to,
## and if so adds the server to the location selector.
class_name AddServerManager extends Node

@export var server_connection_checker: ServerConnectionChecker	## Helper class for checking the server connection
@export var address_field: TextEdit								## Text field for entering the server address
@export var status_field: TextEdit								## Text field for connection status and error messages

const WARN_FONT_COLOR: Color = Color(1.0,0.47,0.41,1)
const DEFAULT_FONT_COLOR: Color = Color(0.87,0.87,0.87,1)

var location_selector: LocationSelector	## The location selector to add the server to

## Initializes the manager with the location selector to add the server to [br][br]
## [param p_location_selector] The location selector to add the server to [br][br]
## [color=yellow]NOTE:[/color] Must be called immediately after initialization
func setup(p_location_selector: LocationSelector) -> void:
	location_selector = p_location_selector

## Callback for clicking the "Add Server" button.
## Checks the server connection and adds the server to the location selector if the connection is successful.
## If the connection fails, an error message is displayed in the status field.
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

## Displays an error message in the status field indicating that the connection to the server failed.
func _display_error() -> void:
	status_field.add_theme_color_override("font_readonly_color", WARN_FONT_COLOR) 
	status_field.text = "UNABLE TO CONNECT TO SERVER!\nIs the entered address correct?"
