class_name ItemChoice
extends Control

## Pantalla de elección de mejora al terminar una oleada.
## Muestra 3 items (una rareza distinta cada uno). El jugador selecciona una
## carta y confirma con el botón "Continuar". Pausa la partida mientras tanto.

signal item_elegido(item: Item)

var _items: Array = []
var _cartas: Array[Button] = []
var _selected: int = 0

var _style_normal: StyleBoxFlat
var _style_seleccion: StyleBoxFlat

@onready var continuar: Button = $Center/Panel/Margin/VBox/Continuar

func _ready() -> void:
	_cartas = [
		$Center/Panel/Margin/VBox/Cartas/Carta0,
		$Center/Panel/Margin/VBox/Cartas/Carta1,
		$Center/Panel/Margin/VBox/Cartas/Carta2,
	]
	_style_normal = _crear_estilo(Color(0.4, 0.4, 0.5, 0.8), Color(0.13, 0.15, 0.2, 1))
	_style_seleccion = _crear_estilo(Color(0.95, 0.75, 0.35, 1.0), Color(0.2, 0.19, 0.15, 1))
	for i in _cartas.size():
		_cartas[i].pressed.connect(_on_carta_pressed.bind(i))
	continuar.pressed.connect(_on_continuar_pressed)

func mostrar(items: Array) -> void:
	_items = items
	for i in _cartas.size():
		var boton := _cartas[i]
		if i < items.size() and items[i] != null:
			var item: Item = items[i]
			boton.text = "%s\n%s\n%s" % [item.nombre, item.get_nombre_rareza(), item.descripcion]
			var color := item.get_color_rareza()
			boton.add_theme_color_override("font_color", color)
			boton.add_theme_color_override("font_hover_color", color.lightened(0.25))
			boton.add_theme_color_override("font_pressed_color", color.lightened(0.4))
			boton.visible = true
		else:
			boton.visible = false
	_selected = 0
	_refrescar_estilos()
	visible = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_carta_pressed(index: int) -> void:
	if index >= _items.size() or index < 0:
		return
	_selected = index
	_refrescar_estilos()

func _on_continuar_pressed() -> void:
	if _selected >= _items.size():
		return
	var item: Item = _items[_selected]
	visible = false
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	item_elegido.emit(item)

func _refrescar_estilos() -> void:
	for i in _cartas.size():
		var boton := _cartas[i]
		if boton.visible:
			var style := _style_seleccion if i == _selected else _style_normal
			boton.add_theme_stylebox_override("normal", style)

func _crear_estilo(borde: Color, fondo: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = fondo
	s.border_color = borde
	s.set_border_width_all(2)
	s.set_corner_radius_all(8)
	return s
