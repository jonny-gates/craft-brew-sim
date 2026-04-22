extends Control

@onready var header_label: Label = $Scroll/VBox/Header
@onready var equipment_list: VBoxContainer = $Scroll/VBox/EquipmentList
@onready var ingredients_list: VBoxContainer = $Scroll/VBox/IngredientsList
@onready var back_button: Button = $Scroll/VBox/BackButton

func _ready() -> void:
	EventBus.cash_changed.connect(_on_cash_changed)
	EventBus.inventory_changed.connect(_on_inventory_changed)
	back_button.pressed.connect(_on_back_pressed)
	_refresh()

func _exit_tree() -> void:
	EventBus.cash_changed.disconnect(_on_cash_changed)
	EventBus.inventory_changed.disconnect(_on_inventory_changed)

func _on_cash_changed(_new_cash: int) -> void:
	_refresh()

func _on_inventory_changed() -> void:
	_refresh()

func _on_back_pressed() -> void:
	(get_parent() as ScreenManager).show_screen("res://screens/inbox/inbox.tscn")

func _refresh() -> void:
	header_label.text = "Shop — $%d" % GameState.cash
	_rebuild_equipment()
	_rebuild_ingredients()

func _rebuild_equipment() -> void:
	for child in equipment_list.get_children():
		child.queue_free()
	for item: EquipmentItem in Catalog.equipment():
		var row := HBoxContainer.new()
		var owned: int = int(GameState.equipment.get(item.id, 0))
		var label := Label.new()
		label.text = "%s — $%d (%s) [owned: %d]" % [item.display_name, item.price, item.capacity_desc, owned]
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var btn := Button.new()
		btn.text = "Buy"
		btn.disabled = GameState.cash < item.price
		btn.pressed.connect(SimEngine.buy_equipment.bind(item.id))
		row.add_child(label)
		row.add_child(btn)
		equipment_list.add_child(row)

func _rebuild_ingredients() -> void:
	for child in ingredients_list.get_children():
		child.queue_free()
	for item: IngredientItem in Catalog.ingredients():
		var row := HBoxContainer.new()
		var have: int = int(GameState.ingredients.get(item.id, 0))
		var label := Label.new()
		label.text = "%s — $%d per %s [have: %d]" % [item.display_name, item.price, item.unit, have]
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var btn := Button.new()
		btn.text = "Buy 1"
		btn.disabled = GameState.cash < item.price
		btn.pressed.connect(SimEngine.buy_ingredient.bind(item.id, 1))
		row.add_child(label)
		row.add_child(btn)
		ingredients_list.add_child(row)
