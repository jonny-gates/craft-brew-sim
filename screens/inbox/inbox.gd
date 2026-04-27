extends Control

@onready var header_label: Label = $VBoxContainer/Header
@onready var message_list: VBoxContainer = $VBoxContainer/MessageList
@onready var shop_button: Button = $VBoxContainer/ShopButton
@onready var recipes_button: Button = $VBoxContainer/RecipesButton
@onready var brewing_button: Button = $VBoxContainer/BrewingButton
@onready var continue_button: Button = $VBoxContainer/ContinueButton

var _selected_id: String = ""

func _ready() -> void:
	EventBus.week_advanced.connect(_on_week_advanced)
	EventBus.inbox_updated.connect(_on_inbox_updated)
	EventBus.cash_changed.connect(_on_cash_changed)
	shop_button.pressed.connect(_on_shop_pressed)
	recipes_button.pressed.connect(_on_recipes_pressed)
	brewing_button.pressed.connect(_on_brewing_pressed)
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
	var unread: int = GameState.inbox.filter(func(m: InboxMessage) -> bool: return not m.read).size()
	header_label.text = "Week %d — $%d  |  %d unread" % [GameState.week, GameState.cash, unread]
	for child in message_list.get_children():
		child.queue_free()
	for msg: InboxMessage in GameState.inbox:
		var row := HBoxContainer.new()

		var dot := Label.new()
		dot.text = "●" if not msg.read else " "
		row.add_child(dot)

		var title_btn := Button.new()
		title_btn.text = "[Week %d] %s" % [msg.week_received, msg.title]
		title_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		title_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		title_btn.flat = true
		title_btn.pressed.connect(_on_message_pressed.bind(msg.id))
		row.add_child(title_btn)

		var del_btn := Button.new()
		del_btn.text = "Delete"
		del_btn.pressed.connect(_on_delete_pressed.bind(msg.id))
		row.add_child(del_btn)

		message_list.add_child(row)

		if _selected_id == msg.id:
			var body := Label.new()
			body.text = msg.body
			body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			message_list.add_child(body)

func _on_message_pressed(msg_id: String) -> void:
	_selected_id = "" if _selected_id == msg_id else msg_id
	SimEngine.mark_read(msg_id)
	_refresh()

func _on_delete_pressed(msg_id: String) -> void:
	if _selected_id == msg_id:
		_selected_id = ""
	SimEngine.delete_message(msg_id)

func _on_shop_pressed() -> void:
	(get_parent() as ScreenManager).show_screen("res://screens/shop/shop.tscn")

func _on_recipes_pressed() -> void:
	(get_parent() as ScreenManager).show_screen("res://screens/recipes/recipes.tscn")

func _on_brewing_pressed() -> void:
	(get_parent() as ScreenManager).show_screen("res://screens/brewing/brewing.tscn")

func _on_continue_pressed() -> void:
	SimEngine.advance_week()
