class_name ArmaFactory
extends RefCounted

## Factory Method para armas.
## Para agregar un arma nueva:
##   1. Crear su script (extendiendo BaseArma).
##   2. Agregar entrada al enum TipoArma.
##   3. Registrarla en el diccionario ARMAS.

enum TipoArma {
	ESPADA,
	BASTON_MAGICO,
	EXPLOSION_FUEGO,
}

const ARMAS := {
	TipoArma.ESPADA: preload("res://armas/espada.gd"),
	TipoArma.BASTON_MAGICO: preload("res://armas/baston_magico.gd"),
	TipoArma.EXPLOSION_FUEGO: preload("res://armas/explosion_fuego.gd"),
}

## Crea y devuelve una instancia fresca del arma solicitada.
static func crear_arma(tipo: TipoArma) -> BaseArma:
	if not ARMAS.has(tipo):
		push_error("ArmaFactory: tipo de arma no registrado (%d)" % tipo)
		return null
	var arma := Node3D.new()
	arma.set_script(ARMAS[tipo])
	return arma as BaseArma

## Devuelve todos los tipos de arma registrados.
static func listar_tipos() -> Array:
	return ARMAS.keys()
