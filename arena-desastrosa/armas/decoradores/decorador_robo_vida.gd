class_name DecoradorRoboVida
extends DecoradorArma

## Decorator – Robo de vida
## Cura al portador cada vez que ejecuta un ataque con éxito.

@export var curacion_por_ataque: int = 6

func _init() -> void:
	nombre = "Robo de vida"

func _on_ataque_decorado(portador: Node3D, _direccion: Vector3) -> void:
	if portador == null:
		return
	var health: Node = portador.get("health")
	if health and health.has_method("heal"):
		health.heal(curacion_por_ataque)
