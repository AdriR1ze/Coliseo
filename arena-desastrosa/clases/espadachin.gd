class_name Espadachin
extends BaseClase

func _init() -> void:
	super._init()
	nombre = "Espadachin"
	salud_maxima = 120
	velocidad = 6.0
	tipo_arma = ArmaFactory.TipoArma.ESPADA
