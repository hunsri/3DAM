extends Tree

func _ready() -> void:
	hide_root = false

	var root = create_item()       # This is the actual root
	root.set_text(0, "My Title")   # Title goes here

	var child1 = create_item(root)
	child1.set_text(0, "Child 1")
	
	var child1_0 = create_item(child1)
	child1_0.set_text(0, "Child 1_0")
	
	var child1_1 = create_item(child1)
	child1_1.set_text(0, "Child 1_1")

	var child2 = create_item(root)
	child2.set_text(0, "Child 2")
