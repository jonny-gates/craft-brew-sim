extends Node

func advance_week() -> void:
	_run_production()
	_run_sales()
	_run_finance()
	_generate_events()
	GameState.week += 1
	_check_recipe_discovery()
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
	_check_recipe_discovery()
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
	_check_recipe_discovery()
	return true

func can_start_batch(recipe_id: String) -> bool:
	var recipe := Catalog.find_recipe(recipe_id)
	if recipe == null:
		return false
	return _has_required_equipment(recipe) and _has_required_ingredients(recipe)

func start_batch(recipe_id: String) -> bool:
	var recipe := Catalog.find_recipe(recipe_id)
	if recipe == null or not can_start_batch(recipe_id):
		return false
	for ingredient_id: String in recipe.ingredient_costs:
		var qty: int = int(recipe.ingredient_costs[ingredient_id])
		GameState.ingredients[ingredient_id] = int(GameState.ingredients.get(ingredient_id, 0)) - qty
	var batch := Batch.new()
	batch.recipe_id = recipe.id
	batch.weeks_remaining = recipe.weeks_to_brew
	batch.started_week = GameState.week
	GameState.batches.append(batch)
	EventBus.inventory_changed.emit()
	EventBus.batches_changed.emit()
	return true

func _run_production() -> void:
	var still_brewing: Array[Batch] = []
	var completed: Array[Batch] = []
	for b: Batch in GameState.batches:
		b.weeks_remaining -= 1
		if b.weeks_remaining <= 0:
			completed.append(b)
		else:
			still_brewing.append(b)
	GameState.batches = still_brewing
	for b: Batch in completed:
		var recipe := Catalog.find_recipe(b.recipe_id)
		if recipe == null:
			continue
		GameState.kegs[recipe.id] = int(GameState.kegs.get(recipe.id, 0)) + recipe.output_kegs
		var msg := InboxMessage.new()
		msg.id = "batch_complete_%s_%d" % [recipe.id, GameState.week]
		msg.week_received = GameState.week
		msg.title = "Batch ready: %s" % recipe.display_name
		msg.body = "%d kegs of %s have finished conditioning." % [recipe.output_kegs, recipe.display_name]
		msg.read = false
		GameState.inbox.append(msg)
	if completed.size() > 0:
		EventBus.batches_changed.emit()

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

func mark_read(msg_id: String) -> void:
	for msg: InboxMessage in GameState.inbox:
		if msg.id == msg_id:
			msg.read = true
			break

func delete_message(msg_id: String) -> void:
	GameState.inbox = GameState.inbox.filter(
		func(m: InboxMessage) -> bool: return m.id != msg_id
	)
	EventBus.inbox_updated.emit()

func _check_recipe_discovery() -> void:
	var changed := false
	for recipe: Recipe in Catalog.recipes():
		if GameState.discovered_recipes.has(recipe.id):
			continue
		if not _has_required_equipment(recipe):
			continue
		if not _has_required_ingredients(recipe):
			continue
		GameState.discovered_recipes.append(recipe.id)
		GameState.recipe_discovery_week[recipe.id] = GameState.week
		changed = true
	if changed:
		EventBus.recipes_changed.emit()

func _has_required_equipment(recipe: Recipe) -> bool:
	for role: String in recipe.equipment_options:
		var options: Array = recipe.equipment_options[role]
		var satisfied := false
		for eq_id: String in options:
			if int(GameState.equipment.get(eq_id, 0)) > 0:
				satisfied = true
				break
		if not satisfied:
			return false
	return true

func _has_required_ingredients(recipe: Recipe) -> bool:
	for ingredient_id: String in recipe.ingredient_costs:
		var need: int = int(recipe.ingredient_costs[ingredient_id])
		if int(GameState.ingredients.get(ingredient_id, 0)) < need:
			return false
	return true
