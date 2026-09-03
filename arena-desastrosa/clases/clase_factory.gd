class_name ClaseFactory
extends RefCounted

enum Clases {
	MAGO,
	ESPADACHIN,
}

const CLASES := {
	Clases.MAGO: preload("res://clases/mago.gd"),
	Clases.ESPADACHIN: preload("res://clases/espadachin.gd"),
}

# Factory Method: crea y devuelve la instancia concreta de la clase pedida.
static func listar_tipos() -> Array:
	return CLASES.keys()

static func crear_clase(tipo: Clases) -> BaseClase:
	if not CLASES.has(tipo):
		push_error("ClaseFactory: tipo de clase no registrado (%d)" % tipo)
		return null
	return CLASES[tipo].new()
