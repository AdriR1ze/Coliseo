class_name MouseLook
extends Node

@export var sensitivity: float = 0.002
@export var min_pitch_deg: float = -60.0
@export var max_pitch_deg: float = 50.0
@export var invert_y: bool = false
@export_node_path("Node3D") var pivot_path: NodePath

var body: Node3D = null
var pivot: Node3D = null
var camera: Camera3D = null
var pitch: float = 0.0

func _ready() -> void:
	body = get_parent() as Node3D
	if not pivot_path.is_empty():
		pivot = get_node_or_null(pivot_path) as Node3D
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			get_viewport().set_input_as_handled()
			return

	if event is InputEventKey and event.pressed and event.physical_keycode == KEY_ESCAPE:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		get_viewport().set_input_as_handled()
		return

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if body:
			body.rotate_y(-event.relative.x * sensitivity)
		
		var y_factor := -1.0 if invert_y else 1.0
		pitch = clampf(
			pitch + event.relative.y * sensitivity * y_factor,
			deg_to_rad(min_pitch_deg),
			deg_to_rad(max_pitch_deg)
		)
		
		if pivot:
			pivot.rotation.x = pitch
		elif camera:
			camera.rotation.x = pitch
