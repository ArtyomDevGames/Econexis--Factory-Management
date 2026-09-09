extends Node3D
class_name RTSCameraController

@export_group("Movement")
@export var move_speed: float = 25.0
@export var pan_smoothness: float = 12.0

@export_group("Zoom")
@export var zoom_speed: float = 3.0
@export var min_zoom: float = 5.0
@export var max_zoom: float = 40.0
@export var zoom_smoothness: float = 10.0

@export_group("Rotation")
@export var rotation_speed: float = 0.005

@onready var camera: Camera3D = $Camera3D

var _target_position: Vector3 = Vector3.ZERO
var _target_zoom: float = 15.0
var _is_rotating: bool = false

func _ready() -> void:
	_target_position = global_position
	if camera:
		_target_zoom = camera.position.z

func _process(delta: float) -> void:
	_handle_movement(delta)
	_handle_zoom(delta)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE or event.button_index == MOUSE_BUTTON_RIGHT:
			_is_rotating = event.pressed
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_target_zoom = clamp(_target_zoom - zoom_speed, min_zoom, max_zoom)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_target_zoom = clamp(_target_zoom + zoom_speed, min_zoom, max_zoom)

	elif event is InputEventMouseMotion and _is_rotating:
		rotate_y(-event.relative.x * rotation_speed)

func _handle_movement(delta: float) -> void:
	var input_dir := Vector2.ZERO

	if Input.is_key_pressed(KEY_A) or Input.is_action_pressed("ui_left"):
		input_dir.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_action_pressed("ui_right"):
		input_dir.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_action_pressed("ui_up"):
		input_dir.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_action_pressed("ui_down"):
		input_dir.y += 1.0

	input_dir = input_dir.normalized()
	
	var move_dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	_target_position += move_dir * move_speed * delta
	global_position = global_position.lerp(_target_position, pan_smoothness * delta)

func _handle_zoom(delta: float) -> void:
	if camera:
		camera.position.z = lerp(camera.position.z, _target_zoom, zoom_smoothness * delta)
