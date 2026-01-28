extends PanelContainer

var is_upload: bool = false 
@export var download_container: PanelContainer
@export var upload_container: PanelContainer

func _on_mode_changer_button_pressed() -> void:
	is_upload = !is_upload 
	
	if is_upload:
		upload_container.visible = true
		download_container.visible = false
	else:
		upload_container.visible = false
		download_container.visible = true
