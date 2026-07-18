extends HScrollBar

@onready var h_scroll_bar: HScrollBar = self
@onready var scroll_container: ScrollContainer = $"../../ScrollContainer"

func _ready() -> void:
	scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	scroll_container.get_h_scroll_bar().share(h_scroll_bar)
