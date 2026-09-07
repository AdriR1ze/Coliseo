extends Node

signal nivel_subido(player: Node, nivel: int)
signal experiencia_actualizada(player: Node, experiencia: int, umbral: int)

var clases_player := {}  # id del jugador -> BaseClase

func get_class_player(player) -> BaseClase:
	return clases_player.get(player.id, null)

func ingresar_clase_player(player, tipo: ClaseFactory.Clases) -> void:
	var clase = ClaseFactory.crear_clase(tipo)
	if clase:
		clases_player[player.id] = clase

func get_nivel(player) -> int:
	var clase := get_class_player(player)
	return clase.nivel if clase else 1

## Suma experiencia a la clase del jugador y sube de nivel al cruzar el umbral.
func subir_experiencia(player, cantidad: int) -> void:
	var clase := get_class_player(player)
	if clase == null:
		return
	clase.experiencia += cantidad
	while clase.experiencia >= clase.experiencia_umbral:
		clase.experiencia -= clase.experiencia_umbral
		clase.nivel += 1
		clase.experiencia_umbral = 5 + (clase.nivel - 1) * 2
		nivel_subido.emit(player, clase.nivel)
	experiencia_actualizada.emit(player, clase.experiencia, clase.experiencia_umbral)
