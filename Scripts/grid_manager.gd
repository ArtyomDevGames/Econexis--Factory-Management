extends Node3D
class_name GridManager

@export_category("Grid Settings")
@export var grid_size: Vector2i = Vector2i(10, 10)
@export var tile_size: float = 2.0

@export_category("Building Settings")
@export var factory_cost: int = 150

var tiles: Dictionary = {}
var is_placement_mode: bool = false
var hovered_tile: PlotTile = null
var preview_mesh: MeshInstance3D

func _ready() -> void:
	_create_preview_mesh()
	_generate_grid()

func _process(_delta: float) -> void:
	if is_placement_mode:
		_update_placement_preview()

func _generate_grid() -> void:
	var start_offset = Vector3(
		- (grid_size.x * tile_size) / 2.0 + tile_size / 2.0,
		0,
		- (grid_size.y * tile_size) / 2.0 + tile_size / 2.0
	)

	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var tile = _create_tile()
			var pos = start_offset + Vector3(x * tile_size, 0, y * tile_size)
			tile.position = pos
			tile.grid_position = Vector2i(x, y)
			
			tile.tile_clicked.connect(_on_tile_clicked)
			
			add_child(tile)
			tiles[Vector2i(x, y)] = tile

func _create_tile() -> PlotTile:
	var tile = PlotTile.new()
	
	var mesh_inst = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(tile_size * 0.95, 0.1, tile_size * 0.95)
	mesh_inst.mesh = box_mesh
	tile.add_child(mesh_inst)
	tile.mesh_instance = mesh_inst
	
	var col = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(tile_size * 0.95, 0.1, tile_size * 0.95)
	col.shape = box_shape
	tile.add_child(col)
	
	return tile

func _create_preview_mesh() -> void:
	preview_mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(tile_size * 0.8, 1.2, tile_size * 0.8)
	preview_mesh.mesh = box
	
	var mat = StandardMaterial3D.new()
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = Color(0, 1, 0, 0.5)
	preview_mesh.material_override = mat
	preview_mesh.visible = false
	add_child(preview_mesh)

func toggle_placement_mode() -> void:
	is_placement_mode = !is_placement_mode
	if not is_placement_mode:
		preview_mesh.visible = false

## Рейкаст из камеры в точку курсора
func _update_placement_preview() -> void:
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return
		
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_end = ray_origin + camera.project_ray_normal(mouse_pos) * 1000.0
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	var result = space_state.intersect_ray(query)
	
	if result and result.collider is PlotTile:
		var tile = result.collider as PlotTile
		hovered_tile = tile
		preview_mesh.visible = true
		preview_mesh.global_position = tile.global_position + Vector3(0, 0.6, 0)
		_update_preview_color(tile)
	else:
		preview_mesh.visible = false
		hovered_tile = null

func _update_preview_color(tile: PlotTile) -> void:
	var mat = preview_mesh.material_override as StandardMaterial3D
	if mat:
		var can_place = tile.is_owned and not tile.is_occupied and EconomyManager.can_afford(factory_cost)
		mat.albedo_color = Color(0, 1, 0, 0.5) if can_place else Color(1, 0, 0, 0.5)

func _on_tile_clicked(tile: PlotTile) -> void:
	if is_placement_mode:
		_try_place_factory(tile)
	else:
		_try_buy_plot(tile)

func _try_buy_plot(tile: PlotTile) -> void:
	if not tile.is_owned:
		tile.buy_plot()

func _try_place_factory(tile: PlotTile) -> void:
	if not tile.is_owned or tile.is_occupied:
		return
		
	if EconomyManager.deduct_coins(factory_cost):
		tile.is_occupied = true
		_spawn_factory_mesh(tile.global_position)
		if hovered_tile:
			_update_preview_color(hovered_tile)

func _spawn_factory_mesh(pos: Vector3) -> void:
	var factory = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(tile_size * 0.8, 1.2, tile_size * 0.8)
	factory.mesh = box
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.2, 0.4, 0.8)
	factory.material_override = mat
	
	factory.position = pos + Vector3(0, 0.6, 0)
	add_child(factory)
