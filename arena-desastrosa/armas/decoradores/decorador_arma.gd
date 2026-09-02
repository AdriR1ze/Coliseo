class_name DecoradorArma
extends BaseArma

## Patrón Decorator para armas.
##
## Envuelve cualquier BaseArma y delega a ella todos los comportamientos
## base, añadiendo lógica extra en _on_ataque_decorado().
##
## Uso:
##   var arma := DecoradorVeneno.new()
##   arma.envolver(ArmaFactory.crear_arma(ArmaFactory.TipoArma.ESPADA))
##   player.add_child(arma)
##
## Se pueden anidar:
##   DecoradorFuego.new().envolver(DecoradorVeneno.new().envolver(espada))

var _arma_interna: BaseArma = null

## Envuelve el arma dada. Debe llamarse antes de agregar el nodo al árbol.
func envolver(arma: BaseArma) -> DecoradorArma:
	if _arma_interna != null:
		push_warning("DecoradorArma: ya hay un arma interna; reemplazando.")
		if is_instance_valid(_arma_interna) and _arma_interna.get_parent() == self:
			_arma_interna.queue_free()
	_arma_interna = arma
	# Reflejar propiedades base desde el arma interna.
	_sincronizar_propiedades()
	return self  # Permite encadenar: decorador.envolver(arma).envolver(otro)

## Refresca las propiedades visibles del decorador desde el arma interna.
func _sincronizar_propiedades() -> void:
	if _arma_interna == null:
		return
	nombre  = _arma_interna.nombre
	dano    = _arma_interna.dano
	cooldown = _arma_interna.cooldown
	alcance = _arma_interna.alcance

func _ready() -> void:
	# Agrega el arma interna como hijo para que pueda usar get_tree().
	if _arma_interna != null and _arma_interna.get_parent() == null:
		add_child(_arma_interna)

# ------------------------------------------------------------------
# Delegación al arma interna
# ------------------------------------------------------------------

func puede_atacar() -> bool:
	if _arma_interna != null:
		return _arma_interna.puede_atacar()
	return super.puede_atacar()

func atacar(portador: Node3D, direccion: Vector3) -> bool:
	if _arma_interna == null:
		push_warning("DecoradorArma: no hay arma interna.")
		return false
	var exito := _arma_interna.atacar(portador, direccion)
	if exito:
		# Sincronizar cooldown interno para que HUD/UI lo lean correctamente.
		_tiempo_restante = _arma_interna._tiempo_restante
		_on_ataque_decorado(portador, direccion)
	return exito

# ------------------------------------------------------------------
# Hook para subclases
# ------------------------------------------------------------------

## Llamado justo después de que el arma interna ejecutó su ataque con éxito.
## Sobreescribir en subclases para añadir efectos extra.
func _on_ataque_decorado(_portador: Node3D, _direccion: Vector3) -> void:
	pass

# ------------------------------------------------------------------
# Utilidades
# ------------------------------------------------------------------

## Devuelve el arma más interna (sin decoradores), útil para debugging.
func get_arma_base() -> BaseArma:
	if _arma_interna is DecoradorArma:
		return (_arma_interna as DecoradorArma).get_arma_base()
	return _arma_interna

## Nombre decorado: apila los nombres para que el HUD muestre la cadena.
func get_nombre_completo() -> String:
	if _arma_interna is DecoradorArma:
		return nombre + " [" + (_arma_interna as DecoradorArma).get_nombre_completo() + "]"
	return nombre + " [" + (_arma_interna.nombre if _arma_interna else "?") + "]"
