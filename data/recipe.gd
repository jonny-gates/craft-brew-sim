extends Resource
class_name Recipe

@export var id: String = ""
@export var display_name: String = ""
@export var style: String = ""
@export var equipment_options: Dictionary = {}
@export var ingredient_costs: Dictionary = {}
@export var weeks_to_brew: int = 1
@export var output_kegs: int = 1
