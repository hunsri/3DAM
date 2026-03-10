class_name LocationSelector extends Control

@export var location_spawner: VBoxContainer
	
func add_server(server_address: String, server_name: String, is_new_server: bool) -> void:
	var server_button := ResourceManager.create_server_button(server_address, server_name, is_new_server)
	location_spawner.add_child(server_button)
