extends Node

## Máquina de estados del flujo del juego y coordinador global.

enum Estado {
	MENU,
	SELECCION_CLASE,
	COMBATE,
	MEJORAS,
	JEFE,
	DERROTA,
}

signal estado_cambiado(anterior: Estado, nuevo: Estado)

var estado_actual: Estado = Estado.MENU
var clase_seleccionada: ClaseFactory.Clases = ClaseFactory.Clases.MAGO

func _ready() -> void:
	_setup_input()

func _setup_input() -> void:
	_agregar_tecla("move_left", KEY_A)
	_agregar_tecla("move_right", KEY_D)
	_agregar_tecla("move_forward", KEY_W)
	_agregar_tecla("move_back", KEY_S)
	_agregar_mouse_button("attack", MOUSE_BUTTON_LEFT)
	_agregar_tecla("attack", KEY_J)
	_agregar_tecla("attack", KEY_F)

func _agregar_tecla(accion: String, tecla: Key) -> void:
	if not InputMap.has_action(accion):
		InputMap.add_action(accion)
	var evento := InputEventKey.new()
	evento.physical_keycode = tecla
	InputMap.action_add_event(accion, evento)

func _agregar_mouse_button(accion: String, button_index: MouseButton) -> void:
	if not InputMap.has_action(accion):
		InputMap.add_action(accion)
	var evento := InputEventMouseButton.new()
	evento.button_index = button_index
	InputMap.action_add_event(accion, evento)

func hacer_bailar_todos() -> void:
	get_tree().call_group("dancers", "bailar")

func seleccionar_clase(tipo: ClaseFactory.Clases) -> void:
	clase_seleccionada = tipo

func ir_a_seleccion_clase() -> void:
	cambiar_estado(Estado.SELECCION_CLASE)

func ir_a_combate() -> void:
	cambiar_estado(Estado.COMBATE)

func ir_a_mejoras() -> void:
	cambiar_estado(Estado.MEJORAS)

func ir_a_jefe() -> void:
	cambiar_estado(Estado.JEFE)

func ir_a_derrota() -> void:
	cambiar_estado(Estado.DERROTA)

func cambiar_estado(nuevo: Estado) -> void:
	if nuevo == estado_actual:
		return
	var anterior := estado_actual
	_salir(anterior)
	estado_actual = nuevo
	_entrar(nuevo)
	estado_cambiado.emit(anterior, nuevo)

func _entrar(_estado: Estado) -> void:
	pass

func _salir(_estado: Estado) -> void:
	pass
