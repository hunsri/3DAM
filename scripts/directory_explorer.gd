extends Tree
@onready var dh: DirectoryHandler = %DirectoryHandler

var _dir
var _show_only_directories: bool = true

func _ready() -> void:
	self.connect("item_selected", Callable(self, "_on_item_selected"))
	
	_dir = DirAccess.open(dh.default_asset_path)
	draw_tree()

func draw_tree() -> void:
	_create_dir()
	_populate_tree()

func _populate_tree() -> void:
	if not _dir:
		return
	clear()
	hide_root = false

	var root_item: TreeItem = create_item()
	root_item.set_text(0, dh.default_library_name)

	_populate_tree_recursive(_dir, root_item, dh.default_asset_path)


func _populate_tree_recursive(dir_access: DirAccess, parent_item: TreeItem, current_path: String) -> void:
	dir_access.list_dir_begin()
	var node_name: String = dir_access.get_next()

	while node_name != "":

		var full_path: String = current_path + "/" + node_name

		# Check whether this entry is a directory (uses DirAccess's current entry flag)
		if dir_access.current_is_dir():
			# Create a new TreeItem for the node
			var dir_item: TreeItem = create_item(parent_item)
			dir_item.set_text(0, node_name)

			# if node is a directory, use recursion to get its children
			var child_dir := DirAccess.open(full_path)
			if child_dir:
				_populate_tree_recursive(child_dir, dir_item, full_path)
		else:
			if not _show_only_directories:
				var file_item: TreeItem = create_item(parent_item)
				file_item.set_text(0, node_name)

		node_name = dir_access.get_next()

	# close the stream if the entry has been completely read
	dir_access.list_dir_end()

func _create_dir() -> void:
	if not _dir:
		var root = DirAccess.open(dh.default_root_dir)
		if root:
			if not root.dir_exists(dh.default_library_name):
				root.make_dir(dh.default_library_name)
		_dir = DirAccess.open(dh.default_asset_path)
