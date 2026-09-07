class_name Item
extends Resource

## Item de mejora otorgado al finalizar una oleada.
## Contiene su rareza, tipo de efecto y el valor del efecto.
## `aplicar()` ejecuta el efecto sobre el jugador.

enum Rareza {
	COMUN,
	RARO,
	EPICO,
	LEGENDARIO,
}

enum TipoEfecto {
	VIDA_MAX,
	DANO,
	VELOCIDAD,
	REDUCCION_COOLDOWN,
	CURACION,
	VENENO,
	FUEGO,
	ROBO_VIDA,
}

@export var nombre: String = "Item"
@export var descripcion: String = ""
@export var rareza: Rareza = Rareza.COMUN
@export var tipo_efecto: TipoEfecto = TipoEfecto.VIDA_MAX
@export var valor: float = 0.0

func get_nombre_rareza() -> String:
	match rareza:
		Rareza.COMUN:
			return "Común"
		Rareza.RARO:
			return "Raro"
		Rareza.EPICO:
			return "Épico"
		Rareza.LEGENDARIO:
			return "Legendario"
	return ""

func get_color_rareza() -> Color:
	match rareza:
		Rareza.COMUN:
			return Color(0.75, 0.75, 0.75)
		Rareza.RARO:
			return Color(0.35, 0.55, 1.0)
		Rareza.EPICO:
			return Color(0.7, 0.35, 1.0)
		Rareza.LEGENDARIO:
			return Color(1.0, 0.8, 0.2)
	return Color.WHITE

func aplicar(jugador: Player) -> void:
	match tipo_efecto:
		TipoEfecto.VIDA_MAX:
			_aplicar_vida_max(jugador)
		TipoEfecto.DANO:
			_aplicar_dano(jugador)
		TipoEfecto.VELOCIDAD:
			_aplicar_velocidad(jugador)
		TipoEfecto.REDUCCION_COOLDOWN:
			_aplicar_reduccion_cooldown(jugador)
		TipoEfecto.CURACION:
			_aplicar_curacion(jugador)
		TipoEfecto.VENENO:
			_aplicar_veneno(jugador)
		TipoEfecto.FUEGO:
			_aplicar_fuego(jugador)
		TipoEfecto.ROBO_VIDA:
			_aplicar_robo_vida(jugador)

# ------------------------------------------------------------------
# Efectos pasivos (stats)
# ------------------------------------------------------------------

func _aplicar_vida_max(jugador: Player) -> void:
	if jugador.health == null:
		return
	jugador.health.max_health += int(valor)
	jugador.health.current_health += int(valor)
	jugador.health.health_changed.emit(jugador.health.current_health, jugador.health.max_health)

func _aplicar_dano(jugador: Player) -> void:
	var arma := _obtener_arma_base(jugador)
	if arma:
		arma.dano += int(valor)

func _aplicar_velocidad(jugador: Player) -> void:
	if jugador.movement:
		jugador.movement.speed += valor

func _aplicar_reduccion_cooldown(jugador: Player) -> void:
	if jugador.habilidad_v == null:
		return
	var nueva := maxf(1.0, jugador.habilidad_v.cooldown_duracion * (1.0 - valor))
	jugador.habilidad_v.cooldown_duracion = nueva
	if jugador.habilidad_v.cooldown_timer:
		jugador.habilidad_v.cooldown_timer.wait_time = nueva

func _aplicar_curacion(jugador: Player) -> void:
	if jugador.health:
		jugador.health.heal(int(valor))

# ------------------------------------------------------------------
# Efectos activos (Decorator sobre el arma)
# ------------------------------------------------------------------

func _aplicar_veneno(jugador: Player) -> void:
	var decorador := DecoradorVeneno.new()
	decorador.dano_veneno = int(valor)
	_envolver_arma(jugador, decorador)

func _aplicar_fuego(jugador: Player) -> void:
	var decorador := DecoradorFuego.new()
	decorador.dano_fuego = int(valor)
	_envolver_arma(jugador, decorador)

func _aplicar_robo_vida(jugador: Player) -> void:
	var decorador := DecoradorRoboVida.new()
	decorador.curacion_por_ataque = int(valor)
	_envolver_arma(jugador, decorador)

## Envuelve el arma actual del jugador con un decorador, si no lo tiene ya.
func _envolver_arma(jugador: Player, decorador: DecoradorArma) -> void:
	if jugador.arma == null:
		decorador.free()
		return
	if _tiene_decorador(jugador.arma, decorador.get_script()):
		decorador.free()
		return
	var arma_actual := jugador.arma
	jugador.remove_child(arma_actual)
	decorador.envolver(arma_actual)
	jugador.arma = decorador
	jugador.add_child(decorador)

func _tiene_decorador(arma: BaseArma, script_tipo: Script) -> bool:
	if arma is DecoradorArma:
		var decorador := arma as DecoradorArma
		if decorador.get_script() == script_tipo:
			return true
		return _tiene_decorador(decorador._arma_interna, script_tipo)
	return false

func _obtener_arma_base(jugador: Player) -> BaseArma:
	if jugador.arma == null:
		return null
	if jugador.arma is DecoradorArma:
		return (jugador.arma as DecoradorArma).get_arma_base()
	return jugador.arma
