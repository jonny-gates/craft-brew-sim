extends Control

@onready var header: Label = $Scroll/VBox/Header
@onready var subheader: Label = $Scroll/VBox/Subheader
@onready var equipment_header: Label = $Scroll/VBox/EquipmentHeader
@onready var equipment_list: VBoxContainer = $Scroll/VBox/EquipmentList
@onready var ingredients_header: Label = $Scroll/VBox/IngredientsHeader
@onready var ingredients_list: VBoxContainer = $Scroll/VBox/IngredientsList
@onready var time_label: Label = $Scroll/VBox/TimeLabel
@onready var output_label: Label = $Scroll/VBox/OutputLabel
@onready var status_label: Label = $Scroll/VBox/StatusLabel
@onready var start_button: Button = $Scroll/VBox/StartBatchButton
@onready var back_button: Button = $Scroll/VBox/BackButton
@onready var confirm_dialog: ConfirmationDialog = $ConfirmDialog

var _recipe_id: String = ""

func _ready() -> void:
	var arg: Variant = (get_parent() as ScreenManager).navigation_arg
	if typeof(arg) == TYPE_STRING:
		_recipe_id = arg
	EventBus.cash_changed.connect(_on_cash_changed)
	EventBus.inventory_changed.connect(_on_inventory_changed)
	back_button.pressed.connect(_on_back_pressed)
	start_button.pressed.connect(_on_start_pressed)
	confirm_dialog.confirmed.connect(_on_confirm)
	_refresh()

func _exit_tree() -> void:
	EventBus.cash_changed.disconnect(_on_cash_changed)
	EventBus.inventory_changed.disconnect(_on_inventory_changed)

func _on_cash_changed(_new_cash: int) -> void:
	_refresh()

func _on_inventory_changed() -> void:
	_refresh()

func _on_back_pressed() -> void:
	(get_parent() as ScreenManager).show_screen("res://screens/recipes/recipes.tscn")

func _on_start_pressed() -> void:
	var recipe := Catalog.find_recipe(_recipe_id)
	if recipe == null:
		return
	var weeks_word: String = "weeks"
	if recipe.weeks_to_brew == 1:
		weeks_word = "week"
	confirm_dialog.title = "Confirm batch"
	confirm_dialog.dialog_text = "Start a batch of %s?\n\nIngredients will be consumed now and the brew will take %d %s." % [recipe.display_name, recipe.weeks_to_brew, weeks_word]
	confirm_dialog.popup_centered()

func _on_confirm() -> void:
	if SimEngine.start_batch(_recipe_id):
		(get_parent() as ScreenManager).show_screen("res://screens/brewing/brewing.tscn")

func _refresh() -> void:
	var recipe := Catalog.find_recipe(_recipe_id)
	if recipe == null:
		header.text = "Recipe not found"
		subheader.text = ""
		status_label.text = ""
		start_button.disabled = true
		return
	header.text = recipe.display_name
	subheader.text = recipe.style
	var weeks_word: String = "weeks"
	if recipe.weeks_to_brew == 1:
		weeks_word = "week"
	time_label.text = "Time to brew: %d %s" % [recipe.weeks_to_brew, weeks_word]
	output_label.text = "Output: %d kegs" % recipe.output_kegs
	_rebuild_equipment(recipe)
	_rebuild_ingredients(recipe)
	var can_start: bool = SimEngine.can_start_batch(_recipe_id)
	start_button.disabled = not can_start
	if can_start:
		status_label.text = "All requirements met."
	else:
		status_label.text = "Missing equipment or ingredients."

func _rebuild_equipment(recipe: Recipe) -> void:
	for child in equipment_list.get_children():
		child.queue_free()
	for role: String in recipe.equipment_options:
		var options: Array = recipe.equipment_options[role]
		var satisfied: bool = false
		var owned_name: String = ""
		for eq_id: String in options:
			if int(GameState.equipment.get(eq_id, 0)) > 0:
				var eq := Catalog.find_equipment(eq_id)
				if eq != null:
					owned_name = eq.display_name
				else:
					owned_name = eq_id
				satisfied = true
				break
		var prefix: String = "[X]" if satisfied else "[ ]"
		var detail: String = ""
		if satisfied:
			detail = " — owned: %s" % owned_name
		else:
			var option_names: Array[String] = []
			for eq_id: String in options:
				var eq := Catalog.find_equipment(eq_id)
				if eq != null:
					option_names.append(eq.display_name)
				else:
					option_names.append(eq_id)
			detail = " — need any of: %s" % _join(option_names, ", ")
		var label := Label.new()
		label.text = "%s %s%s" % [prefix, role, detail]
		equipment_list.add_child(label)

func _rebuild_ingredients(recipe: Recipe) -> void:
	for child in ingredients_list.get_children():
		child.queue_free()
	for ingredient_id: String in recipe.ingredient_costs:
		var need: int = int(recipe.ingredient_costs[ingredient_id])
		var have: int = int(GameState.ingredients.get(ingredient_id, 0))
		var ing := Catalog.find_ingredient(ingredient_id)
		var ing_name: String = ingredient_id
		if ing != null:
			ing_name = ing.display_name
		var prefix: String = "[X]" if have >= need else "[ ]"
		var label := Label.new()
		label.text = "%s %s — %d / %d" % [prefix, ing_name, have, need]
		ingredients_list.add_child(label)

func _join(parts: Array[String], sep: String) -> String:
	var out: String = ""
	for i: int in parts.size():
		if i > 0:
			out += sep
		out += parts[i]
	return out
