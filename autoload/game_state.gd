extends Node

var save_version: int = 2
var week: int = 1
var cash: int = 10000
var inbox: Array[InboxMessage] = []
var equipment: Dictionary[String, int] = {}
var ingredients: Dictionary[String, int] = {}

func reset() -> void:
	save_version = 2
	week = 1
	cash = 10000
	inbox = []
	equipment = {}
	ingredients = {}
