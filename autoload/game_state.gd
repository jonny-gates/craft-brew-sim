extends Node

var save_version: int = 3
var week: int = 1
var cash: int = 10000
var inbox: Array[InboxMessage] = []
var equipment: Dictionary[String, int] = {}
var ingredients: Dictionary[String, int] = {}
var discovered_recipes: Array[String] = []
var recipe_discovery_week: Dictionary[String, int] = {}
var batches: Array[Batch] = []
var kegs: Dictionary[String, int] = {}

func reset() -> void:
	save_version = 3
	week = 1
	cash = 10000
	inbox = []
	equipment = {}
	ingredients = {}
	discovered_recipes = []
	recipe_discovery_week = {}
	batches = []
	kegs = {}
