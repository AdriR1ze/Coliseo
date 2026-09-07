class_name ItemFactory
extends RefCounted

## Base de datos de items y Factory Method.
## Para agregar un item:
##   1. Agregar una entrada al enum ItemID.
##   2. Registrarlo en el diccionario ITEMS con su rareza, efecto y valor.

enum ItemID {
	POCION_MENOR,
	BOTAS_LIGERAS,
	CORAZON_CUERO,
	CORAZON_HIERRO,
	FILO_AFILADO,
	MENTE_CLARA,
	CORAZON_TITAN,
	HOJA_RUNICA,
	VENENO_LETAL,
	ALMA_FENIX,
	FUEGO_ETERNO,
	SANGUIJUELA,
	BOTAS_VIENTO,
}

const ITEMS := {
	ItemID.POCION_MENOR: {
		"nombre": "Poción menor",
		"descripcion": "Recupera 25 de vida.",
		"rareza": Item.Rareza.COMUN,
		"tipo_efecto": Item.TipoEfecto.CURACION,
		"valor": 25.0,
	},
	ItemID.BOTAS_LIGERAS: {
		"nombre": "Botas ligeras",
		"descripcion": "Aumenta tu velocidad en 0.4.",
		"rareza": Item.Rareza.COMUN,
		"tipo_efecto": Item.TipoEfecto.VELOCIDAD,
		"valor": 0.4,
	},
	ItemID.CORAZON_CUERO: {
		"nombre": "Corazón de cuero",
		"descripcion": "Aumenta tu vida máxima en 15.",
		"rareza": Item.Rareza.COMUN,
		"tipo_efecto": Item.TipoEfecto.VIDA_MAX,
		"valor": 15.0,
	},
	ItemID.CORAZON_HIERRO: {
		"nombre": "Corazón de hierro",
		"descripcion": "Aumenta tu vida máxima en 30.",
		"rareza": Item.Rareza.RARO,
		"tipo_efecto": Item.TipoEfecto.VIDA_MAX,
		"valor": 30.0,
	},
	ItemID.FILO_AFILADO: {
		"nombre": "Filo afilado",
		"descripcion": "Aumenta el daño de tu arma en 8.",
		"rareza": Item.Rareza.RARO,
		"tipo_efecto": Item.TipoEfecto.DANO,
		"valor": 8.0,
	},
	ItemID.MENTE_CLARA: {
		"nombre": "Mente clara",
		"descripcion": "Reduce el cooldown de la habilidad un 12%.",
		"rareza": Item.Rareza.RARO,
		"tipo_efecto": Item.TipoEfecto.REDUCCION_COOLDOWN,
		"valor": 0.12,
	},
	ItemID.CORAZON_TITAN: {
		"nombre": "Corazón de titán",
		"descripcion": "Aumenta tu vida máxima en 60.",
		"rareza": Item.Rareza.EPICO,
		"tipo_efecto": Item.TipoEfecto.VIDA_MAX,
		"valor": 60.0,
	},
	ItemID.HOJA_RUNICA: {
		"nombre": "Hoja rúnica",
		"descripcion": "Aumenta el daño de tu arma en 18.",
		"rareza": Item.Rareza.EPICO,
		"tipo_efecto": Item.TipoEfecto.DANO,
		"valor": 18.0,
	},
	ItemID.VENENO_LETAL: {
		"nombre": "Veneno letal",
		"descripcion": "Tus ataques envenenan a los enemigos.",
		"rareza": Item.Rareza.EPICO,
		"tipo_efecto": Item.TipoEfecto.VENENO,
		"valor": 6.0,
	},
	ItemID.ALMA_FENIX: {
		"nombre": "Alma de fénix",
		"descripcion": "Aumenta tu vida máxima en 100.",
		"rareza": Item.Rareza.LEGENDARIO,
		"tipo_efecto": Item.TipoEfecto.VIDA_MAX,
		"valor": 100.0,
	},
	ItemID.FUEGO_ETERNO: {
		"nombre": "Fuego eterno",
		"descripcion": "Tus ataques queman a los enemigos.",
		"rareza": Item.Rareza.LEGENDARIO,
		"tipo_efecto": Item.TipoEfecto.FUEGO,
		"valor": 20.0,
	},
	ItemID.SANGUIJUELA: {
		"nombre": "Sanguijuela",
		"descripcion": "Robas vida con cada ataque.",
		"rareza": Item.Rareza.LEGENDARIO,
		"tipo_efecto": Item.TipoEfecto.ROBO_VIDA,
		"valor": 10.0,
	},
	ItemID.BOTAS_VIENTO: {
		"nombre": "Botas del viento",
		"descripcion": "Aumenta tu velocidad en 1.0.",
		"rareza": Item.Rareza.LEGENDARIO,
		"tipo_efecto": Item.TipoEfecto.VELOCIDAD,
		"valor": 1.0,
	},
}

static func crear_item(id: ItemID) -> Item:
	if not ITEMS.has(id):
		push_error("ItemFactory: item no registrado (%d)" % id)
		return null
	var datos: Dictionary = ITEMS[id]
	var item := Item.new()
	item.nombre = datos["nombre"]
	item.descripcion = datos["descripcion"]
	item.rareza = datos["rareza"]
	item.tipo_efecto = datos["tipo_efecto"]
	item.valor = datos["valor"]
	return item

static func listar_items() -> Array:
	return ITEMS.keys()

## Devuelve 3 items aleatorios, cada uno de una rareza distinta.
static func obtener_tres_aleatorios() -> Array:
	var rarezas: Array = [
		Item.Rareza.COMUN,
		Item.Rareza.RARO,
		Item.Rareza.EPICO,
		Item.Rareza.LEGENDARIO,
	]
	rarezas.shuffle()
	var elegidos: Array = []
	for rareza in rarezas.slice(0, 3):
		var item := _item_aleatorio_de_rareza(rareza)
		if item:
			elegidos.append(item)
	return elegidos

static func _item_aleatorio_de_rareza(rareza: Item.Rareza) -> Item:
	var candidatos: Array = []
	for id in ITEMS:
		if ITEMS[id]["rareza"] == rareza:
			candidatos.append(id)
	if candidatos.is_empty():
		return null
	return crear_item(candidatos.pick_random())
