class_name HabilidadV
extends Node

## Componente para gestionar la habilidad especial de la tecla V y su cooldown.
## Emite señales Observer para mantener desacoplada la lógica de la UI.

signal cooldown_iniciado(duracion: float)
signal cooldown_actualizado(tiempo_restante: float, duracion: float)
signal cooldown_finalizado()

@export var cooldown_duracion: float = 10.0

@onready var cooldown_timer: Timer = $TimerCooldown

func _ready() -> void:
	if cooldown_timer:
		cooldown_timer.wait_time = cooldown_duracion
		cooldown_timer.one_shot = true
		if not cooldown_timer.timeout.is_connected(_on_timer_timeout):
			cooldown_timer.timeout.connect(_on_timer_timeout)

func puede_usarse() -> bool:
	if cooldown_timer == null:
		return false
	return cooldown_timer.is_stopped()

func ejecutar(player: Player) -> bool:
	if not puede_usarse():
		return false
	if player == null or player._is_dead:
		return false

	cooldown_timer.start(cooldown_duracion)
	cooldown_iniciado.emit(cooldown_duracion)

	# Delegación a través del patrón Command en la clase del jugador
	var clase: BaseClase = ClassManager.get_class_player(player)
	if clase and clase.has_method("v_command"):
		clase.v_command(player)
	else:
		# Fallback directo al comando de explosión de fuego
		var cmd := preload("res://clases/comandos/comando_explosion_fuego.gd").new()
		cmd.execute(player)

	return true

func _process(_delta: float) -> void:
	if cooldown_timer and not cooldown_timer.is_stopped():
		cooldown_actualizado.emit(cooldown_timer.time_left, cooldown_duracion)

func _on_timer_timeout() -> void:
	cooldown_finalizado.emit()
