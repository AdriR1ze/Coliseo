class_name BaseArma
extends Node3D

signal atacado

@export var nombre: String = "Arma Base"
@export var dano: int = 20
@export var cooldown: float = 0.5
@export var alcance: float = 2.0

var _tiempo_restante: float = 0.0

func _physics_process(delta: float) -> void:
	if _tiempo_restante > 0.0:
		_tiempo_restante = maxf(0.0, _tiempo_restante - delta)

func puede_atacar() -> bool:
	return _tiempo_restante <= 0.0

func atacar(_portador: Node3D, _direccion: Vector3) -> bool:
	if not puede_atacar():
		return false
	_tiempo_restante = cooldown
	atacado.emit()
	return true
