class_name EnemyFactory
extends RefCounted

## Para agregar un nuevo enemigo:
##   1. Crear su escena/script (extendiendo Enemy).
##   2. Agregar su entrada al enum TipoEnemigo.
##   3. Registrarla en el diccionario ENEMIGOS.

enum TipoEnemigo {
	BASICO,
	RAPIDO,
	TANQUE,
	JEFE,
}

const ENEMIGOS := {
	TipoEnemigo.BASICO: preload("res://enemy.tscn"),
}

static func crear_enemigo(tipo: TipoEnemigo) -> Enemy:
	if not ENEMIGOS.has(tipo):
		push_error("EnemyFactory: tipo de enemigo no registrado (%d)" % tipo)
		return null
	return ENEMIGOS[tipo].instantiate()
