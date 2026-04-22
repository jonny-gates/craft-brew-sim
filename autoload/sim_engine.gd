extends Node

func advance_week() -> void:
	_run_production()
	_run_sales()
	_run_finance()
	_generate_events()
	GameState.week += 1
	EventBus.week_advanced.emit(GameState.week)
	EventBus.inbox_updated.emit()

func buy_equipment(id: String) -> bool:
	var item := Catalog.find_equipment(id)
	if item == null or GameState.cash < item.price:
		return false
	GameState.cash -= item.price
	GameState.equipment[id] = int(GameState.equipment.get(id, 0)) + 1
	EventBus.cash_changed.emit(GameState.cash)
	EventBus.inventory_changed.emit()
	return true

func buy_ingredient(id: String, quantity: int = 1) -> bool:
	var item := Catalog.find_ingredient(id)
	if item == null or quantity <= 0:
		return false
	var total: int = item.price * quantity
	if GameState.cash < total:
		return false
	GameState.cash -= total
	GameState.ingredients[id] = int(GameState.ingredients.get(id, 0)) + quantity
	EventBus.cash_changed.emit(GameState.cash)
	EventBus.inventory_changed.emit()
	return true

func _run_production() -> void:
	pass  # TODO: implement production phase

func _run_sales() -> void:
	pass  # TODO: implement sales phase

func _run_finance() -> void:
	pass  # TODO: implement finance phase

func _generate_events() -> void:
	# TODO: implement event generation
	var msg := InboxMessage.new()
	msg.id = "placeholder_%d" % GameState.week
	msg.week_received = GameState.week
	msg.title = "Week %d Update" % GameState.week
	msg.body = "Placeholder event for week %d." % GameState.week
	msg.read = false
	GameState.inbox.append(msg)
