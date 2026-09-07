class_name HealthBar
extends Control

## Barra de vida (corazón + barra). Se actualiza con la señal de salud del jugador.

@onready var bar: ProgressBar = $Root/Bar

func setup(jugador: Player) -> void:
	if jugador == null or jugador.health == null:
		return
	if not jugador.health.health_changed.is_connected(_on_health_changed):
		jugador.health.health_changed.connect(_on_health_changed)
	_on_health_changed(jugador.health.current_health, jugador.health.max_health)

func _on_health_changed(current: int, max_health: int) -> void:
	if bar == null:
		return
	bar.max_value = max_health
	bar.value = current
