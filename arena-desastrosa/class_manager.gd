extends Node

var clases_player := {}  # id del jugador -> BaseClase

func get_class_player(player) -> BaseClase:
	return clases_player.get(player.id, null)

func ingresar_clase_player(player, tipo: ClaseFactory.Clases) -> void:
	var clase = ClaseFactory.crear_clase(tipo)
	if clase:
		clases_player[player.id] = clase
