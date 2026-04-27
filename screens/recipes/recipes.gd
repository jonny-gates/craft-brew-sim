extends Control

@onready var header_label: Label = $Scroll/VBox/Header
@onready var empty_label: Label = $Scroll/VBox/EmptyLabel
@onready var recipe_list: VBoxContainer = $Scroll/VBox/RecipeList
@onready var back_button: Button = $Scroll/VBox/BackButton

func _ready() -> void:
	EventBus.recipes_changed.connect(_on_recipes_changed)
	EventBus.week_advanced.connect(_on_week_advanced)
	EventBus.inventory_changed.connect(_on_inventory_changed)
	back_button.pressed.connect(_on_back_pressed)
	_refresh()

func _exit_tree() -> void:
	EventBus.recipes_changed.disconnect(_on_recipes_changed)
	EventBus.week_advanced.disconnect(_on_week_advanced)
	EventBus.inventory_changed.disconnect(_on_inventory_changed)

func _on_recipes_changed() -> void:
	_refresh()

func _on_week_advanced(_new_week: int) -> void:
	_refresh()

func _on_inventory_changed() -> void:
	_refresh()

func _on_back_pressed() -> void:
	(get_parent() as ScreenManager).show_screen("res://screens/inbox/inbox.tscn")

func _refresh() -> void:
	header_label.text = "Recipes — Week %d" % GameState.week
	for child in recipe_list.get_children():
		child.queue_free()
	var ids: Array[String] = GameState.discovered_recipes.duplicate()
	if ids.is_empty():
		empty_label.visible = true
		recipe_list.visible = false
		return
	empty_label.visible = false
	recipe_list.visible = true
	var current_week: int = GameState.week
	var new_ids: Array[String] = []
	var old_ids: Array[String] = []
	for id: String in ids:
		if int(GameState.recipe_discovery_week.get(id, 0)) == current_week:
			new_ids.append(id)
		else:
			old_ids.append(id)
	new_ids.sort_custom(_alpha)
	old_ids.sort_custom(_alpha)
	for id: String in new_ids:
		_add_row(id, true)
	for id: String in old_ids:
		_add_row(id, false)

func _alpha(a: String, b: String) -> bool:
	var ra := Catalog.find_recipe(a)
	var rb := Catalog.find_recipe(b)
	var na: String = a
	var nb: String = b
	if ra != null:
		na = ra.display_name
	if rb != null:
		nb = rb.display_name
	return na.naturalnocasecmp_to(nb) < 0

func _add_row(recipe_id: String, is_new: bool) -> void:
	var recipe := Catalog.find_recipe(recipe_id)
	if recipe == null:
		return
	var btn := Button.new()
	var prefix: String = "[NEW] " if is_new else ""
	btn.text = "%s%s — %s" % [prefix, recipe.display_name, recipe.style]
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.pressed.connect(_open_detail.bind(recipe_id))
	recipe_list.add_child(btn)

func _open_detail(recipe_id: String) -> void:
	(get_parent() as ScreenManager).show_screen("res://screens/recipes/recipe_detail.tscn", recipe_id)
