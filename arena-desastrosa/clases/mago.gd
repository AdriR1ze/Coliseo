class_name Mago
extends BaseClase

func _init() -> void:
	super._init()
	nombre = "Mago"
	salud_maxima = 80
	velocidad = 4.0
	tipo_arma = ArmaFactory.TipoArma.BASTON_MAGICO

func v_command(usuario: Node3D = null) -> void:
	super.v_command(usuario)
	
