extends Node

signal coins_changed(new_amount: int)

@export var coins: int = 1000

func _ready() -> void:
	coins_changed.emit(coins)

func can_afford(cost: int) -> bool:
	return coins >= cost

func add_coins(amount: int) -> void:
	if amount <= 0:
		return
	coins += amount
	coins_changed.emit(coins)

func deduct_coins(amount: int) -> bool:
	if can_afford(amount):
		coins -= amount
		coins_changed.emit(coins)
		return true
	return false
