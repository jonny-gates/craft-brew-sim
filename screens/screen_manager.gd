extends Control
class_name ScreenManager

var _current_screen: Control = null

func _ready() -> void:
	show_screen("res://screens/inbox/inbox.tscn")

func show_screen(path: String) -> void:
	if _current_screen != null:
		remove_child(_current_screen)
		_current_screen.queue_free()
	var scene: PackedScene = load(path)
	_current_screen = scene.instantiate()
	add_child(_current_screen)
