class_name Comment extends HFlowContainer

@export var comment_author_label: Label
@export var comment_text_label: Label

func setup(comment_author: String, comment_text: String) -> void:
	comment_author_label.text = comment_author
	comment_text_label.text = comment_text
