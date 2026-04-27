extends Control

@onready var header_label: Label = $Scroll/VBox/Header
@onready var empty_label: Label = $Scroll/VBox/EmptyLabel
@onready var batch_list: VBoxContainer = $Scroll/VBox/BatchList
@onready var back_button: Button = $Scroll/VBox/BackButton

func _ready() -> void:
	EventBus.batches_changed.connect(_on_batches_changed)
	EventBus.week_advanced.connect(_on_week_advanced)
	back_button.pressed.connect(_on_back_pressed)
	_refresh()

func _exit_tree() -> void:
	EventBus.batches_changed.disconnect(_on_batches_changed)
	EventBus.week_advanced.disconnect(_on_week_advanced)

func _on_batches_changed() -> void:
	_refresh()

func _on_week_advanced(_new_week: int) -> void:
	_refresh()

func _on_back_pressed() -> void:
	(get_parent() as ScreenManager).show_screen("res://screens/inbox/inbox.tscn")

func _refresh() -> void:
	header_label.text = "Brewing — Week %d" % GameState.week
	for child in batch_list.get_children():
		child.queue_free()
	if GameState.batches.is_empty():
		empty_label.visible = true
		batch_list.visible = false
		return
	empty_label.visible = false
	batch_list.visible = true
	var sorted: Array[Batch] = GameState.batches.duplicate()
	sorted.sort_custom(_by_time_remaining)
	for b: Batch in sorted:
		var recipe := Catalog.find_recipe(b.recipe_id)
		var recipe_name: String = b.recipe_id
		if recipe != null:
			recipe_name = recipe.display_name
		var weeks_word: String = "weeks"
		if b.weeks_remaining == 1:
			weeks_word = "week"
		var label := Label.new()
		label.text = "%s — %d %s remaining (started week %d)" % [recipe_name, b.weeks_remaining, weeks_word, b.started_week]
		batch_list.add_child(label)

func _by_time_remaining(a: Batch, b: Batch) -> bool:
	return a.weeks_remaining < b.weeks_remaining
