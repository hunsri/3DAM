class_name LocationSelector extends Control

@export var location_spawner: VBoxContainer
	
func add_server(server_address: String) -> void:
	var server_button := ResourceManager.create_server_button(server_address)
	location_spawner.add_child(server_button)
