extends CanvasLayer

@export var grid_manager: Node3D

@onready var coins_label: Label = $Control/CoinsLabel
@onready var buy_factory_button: Button = $Control/BuyFactoryButton

func _ready() -> void:
	EconomyManager.coins_changed.connect(_on_coins_changed)
	coins_label.text = "$: %d" % EconomyManager.coins
	
	buy_factory_button.pressed.connect(_on_buy_factory_pressed)

func _on_coins_changed(new_amount: int) -> void:
	coins_label.text = "$: %d" % new_amount

func _on_buy_factory_pressed() -> void:
	if grid_manager:
		grid_manager.toggle_placement_mode()
		if grid_manager.is_placement_mode:
			buy_factory_button.text = "Stop"
		else:
			buy_factory_button.text = "Build a factory ($150)"
	else:
		print("ОШИБКА: Поле Grid Manager не перетащено в Инспекторе!")
