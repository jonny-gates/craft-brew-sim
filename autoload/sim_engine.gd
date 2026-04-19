extends Node

func advance_week() -> void:
	_run_production()
	_run_sales()
	_run_finance()
	_generate_events()
	GameState.week += 1
	EventBus.week_advanced.emit(GameState.week)
	EventBus.inbox_updated.emit()

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
