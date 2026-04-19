extends Node

var save_version: int = 1
var week: int = 1
var cash: int = 10000
var inbox: Array[InboxMessage] = []

func reset() -> void:
	save_version = 1
	week = 1
	cash = 10000
	inbox = []
