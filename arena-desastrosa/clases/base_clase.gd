class_name BaseClase
extends Resource

@export var nombre: String = "Base"
@export var salud_maxima: int = 100
@export var velocidad: float = 5.0
## Tipo de arma base de esta clase. El Factory Method la instancia en crear_arma().
@export var tipo_arma: ArmaFactory.TipoArma = ArmaFactory.TipoArma.ESPADA

## Progresión de nivel de la clase (solo informativa por ahora).
var nivel: int = 1
var experiencia: int = 0
var experiencia_umbral: int = 5

## Factory Method: crea y devuelve el arma base de esta clase.
## Para aplicar decoradores, la subclase puede sobreescribir este método
## y envolver el arma antes de devolverla. Ejemplo:
##   var arma := super.crear_arma()
##   return DecoradorFuego.new().envolver(arma)
func crear_arma() -> BaseArma:
	return ArmaFactory.crear_arma(tipo_arma)

func describir() -> String:
	return "%s (Salud: %d, Velocidad: %.1f)" % [nombre, salud_maxima, velocidad]
var comando_v: RefCounted = null

func _init() -> void:
	comando_v = preload("res://clases/comandos/comando_explosion_fuego.gd").new()

## Command Pattern: Ejecuta la acción especial asignada a la tecla V.
func v_command(usuario: Node3D = null) -> void:
	if comando_v and comando_v.has_method("execute"):
		comando_v.execute(usuario)
