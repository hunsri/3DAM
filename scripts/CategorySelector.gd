class_name CategorySelector extends Tree

func draw_tree(categories: Array) -> void:
	var root_item: TreeItem = create_item()
	
	hide_root = true
	root_item.set_text(0, "root")
	
	for i in categories.size():
		var category_item = create_item(root_item)
		category_item.set_text(0, categories[i])
	
