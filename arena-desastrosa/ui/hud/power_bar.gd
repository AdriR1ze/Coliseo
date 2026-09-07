class_name PowerBar
extends Control

## Barra de energía / progreso de nivel de clase. Muestra el nivel y el XP acumulado.

@onready var bar: ProgressBar = $Root/Bar
@onready var nivel_label: Label = $Root/Nivel

var _jugador: Player = null

func setup(jugador: Player) -> void:
	_jugador = jugador
	if not ClassManager.experiencia_actualizada.is_connected(_on_xp):
		ClassManager.experiencia_actualizada.connect(_on_xp)
	if not ClassManager.nivel_subido.is_connected(_on_nivel):
		ClassManager.nivel_subido.connect(_on_nivel)
	var clase: BaseClase = ClassManager.get_class_player(jugador)
	if clase:
		_on_xp(jugador, clase.experiencia, clase.experiencia_umbral)
		_on_nivel(jugador, clase.nivel)

func _on_xp(player: Node, xp: int, umbral: int) -> void:
	if player != _jugador or bar == null:
		return
	bar.max_value = umbral if umbral > 0 else 1
	bar.value = xp

func _on_nivel(player: Node, nivel: int) -> void:
	if player == _jugador and nivel_label:
		nivel_label.text = "Nv. %d" % nivel
