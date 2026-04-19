extends Control

func _ready() -> void:
	$VBoxContainer/NameLabel.text = name
	$VBoxContainer/BackButton.pressed.connect(_on_back_pressed)

func _on_back_pressed() -> void:
	(get_parent() as ScreenManager).show_screen("res://screens/inbox/inbox.tscn")
