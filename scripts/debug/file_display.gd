extends Label

var target_dir := "res://Assets"
var label: Label

func _ready() -> void:
	label = self
	_refresh()

func _refresh() -> void:
	var items: Array[String] = []
	var dir := DirAccess.open(target_dir)
	if dir == null:
		label.text = "Could not open: %s" % target_dir
		return

	dir.list_dir_begin()
	while true:
		var name := dir.get_next()
		if name == "":
			break
		if not name.begins_with("."):
			items.append(name)
	dir.list_dir_end()

	label.text = "\n".join(items)
