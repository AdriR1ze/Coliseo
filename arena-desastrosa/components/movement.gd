class_name Movement
extends Node

@export var speed: float = 5.0
@export var jump_velocity: float = 4.5

var body: CharacterBody3D
var active: bool = true

func _ready() -> void:
	body = get_parent() as CharacterBody3D

func _physics_process(delta: float) -> void:
	if not active or body == null:
		return
	if not body.is_on_floor():
		body.velocity += body.get_gravity() * delta
	body.move_and_slide()

func mover(direccion: Vector3) -> void:
	body.velocity.x = direccion.x * speed
	body.velocity.z = direccion.z * speed

func frenar() -> void:
	body.velocity.x = move_toward(body.velocity.x, 0.0, speed)
	body.velocity.z = move_toward(body.velocity.z, 0.0, speed)

func saltar() -> void:
	if body.is_on_floor():
		body.velocity.y = jump_velocity

func detener() -> void:
	body.velocity = Vector3.ZERO
