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
		var _name := dir.get_next()
		if _name == "":
			break
		if not _name.begins_with("."):
			items.append(_name)
	dir.list_dir_end()

	label.text = "\n".join(items)
