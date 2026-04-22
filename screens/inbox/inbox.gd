extends Control

@onready var header_label: Label = $VBoxContainer/Header
@onready var message_list: VBoxContainer = $VBoxContainer/MessageList
@onready var shop_button: Button = $VBoxContainer/ShopButton
@onready var continue_button: Button = $VBoxContainer/ContinueButton

func _ready() -> void:
	EventBus.week_advanced.connect(_on_week_advanced)
	EventBus.inbox_updated.connect(_on_inbox_updated)
	EventBus.cash_changed.connect(_on_cash_changed)
	shop_button.pressed.connect(_on_shop_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	_refresh()

func _exit_tree() -> void:
	EventBus.week_advanced.disconnect(_on_week_advanced)
	EventBus.inbox_updated.disconnect(_on_inbox_updated)
	EventBus.cash_changed.disconnect(_on_cash_changed)

func _on_week_advanced(_new_week: int) -> void:
	_refresh()

func _on_inbox_updated() -> void:
	_refresh()

func _on_cash_changed(_new_cash: int) -> void:
	_refresh()

func _refresh() -> void:
	header_label.text = "Week %d — $%d" % [GameState.week, GameState.cash]
	for child in message_list.get_children():
		child.queue_free()
	for msg: InboxMessage in GameState.inbox:
		var label := Label.new()
		label.text = "[Week %d] %s" % [msg.week_received, msg.title]
		message_list.add_child(label)

func _on_shop_pressed() -> void:
	(get_parent() as ScreenManager).show_screen("res://screens/shop/shop.tscn")

func _on_continue_pressed() -> void:
	SimEngine.advance_week()
