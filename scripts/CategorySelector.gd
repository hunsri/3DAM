class_name CategorySelector extends Tree

func draw_tree(categories: Array) -> void:
	var root_item: TreeItem = create_item()
	
	hide_root = true
	root_item.set_text(0, "root")
	
	for i in categories.size():
		var category_item = create_item(root_item)
		category_item.set_text(0, categories[i])

func force_selection_of_first_child() -> void:	
	# includes null-check
	set_selected(get_root().get_first_child(), 0)
