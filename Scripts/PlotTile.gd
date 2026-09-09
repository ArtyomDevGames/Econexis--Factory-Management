extends Area3D
class_name PlotTile

signal tile_clicked(tile: PlotTile)
signal tile_hovered(tile: PlotTile)

@export var buy_cost: int = 100

var grid_position: Vector2i = Vector2i.ZERO
var is_owned: bool = false
var is_occupied: bool = false

var mesh_instance: MeshInstance3D
var unowned_material: StandardMaterial3D
var owned_material: StandardMaterial3D

func _ready() -> void:
	unowned_material = StandardMaterial3D.new()
	unowned_material.albedo_color = Color(0.25, 0.25, 0.25)

	owned_material = StandardMaterial3D.new()
	owned_material.albedo_color = Color(0.2, 0.6, 0.3)

	_update_visuals()

	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)

func _on_input_event(_camera: Node, event: InputEvent, _pos: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		tile_clicked.emit(self)

func _on_mouse_entered() -> void:
	tile_hovered.emit(self)

func buy_plot() -> bool:
	if is_owned:
		return false
	if EconomyManager.deduct_coins(buy_cost):
		is_owned = true
		_update_visuals()
		return true
	return false

func _update_visuals() -> void:
	if mesh_instance:
		mesh_instance.material_override = owned_material if is_owned else unowned_material
