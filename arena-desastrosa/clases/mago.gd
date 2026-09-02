class_name Mago
extends BaseClase

func _init() -> void:
	nombre = "Mago"
	salud_maxima = 80
	velocidad = 4.0
	tipo_arma = ArmaFactory.TipoArma.BASTON_MAGICO
