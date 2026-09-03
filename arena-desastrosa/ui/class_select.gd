class_name ClassSelectUI
extends Control

var clase_seleccionada: ClaseFactory.Clases = ClaseFactory.Clases.MAGO
var _grupo_botones := ButtonGroup.new()

func _ready() -> void:
	_construir_ui()

func _construir_ui() -> void:
	# Fondo oscuro de la pantalla de selección
	var fondo := ColorRect.new()
	fondo.color = Color(0.07, 0.08, 0.12)
	fondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(fondo)

	var center := CenterContainer.new()
	add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 24)
	center.add_child(vbox)

	var titulo := Label.new()
	titulo.text = "Elegí tu clase"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_font_size_override("font_size", 32)
	vbox.add_child(titulo)

	var subtitulo := Label.new()
	subtitulo.text = "Cada clase empuña su propia arma"
	subtitulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitulo.add_theme_font_size_override("font_size", 15)
	subtitulo.add_theme_color_override("font_color", Color(0.7, 0.7, 0.75))
	vbox.add_child(subtitulo)

	var fila := HBoxContainer.new()
	fila.alignment = BoxContainer.ALIGNMENT_CENTER
	fila.add_theme_constant_override("separation", 16)
	vbox.add_child(fila)

	for tipo in ClaseFactory.listar_tipos():
		fila.add_child(_crear_card(tipo))

	var comenzar := Button.new()
	comenzar.text = "Comenzar"
	comenzar.custom_minimum_size = Vector2(200, 44)
	comenzar.pressed.connect(_on_comenzar)
	vbox.add_child(comenzar)

func _crear_card(tipo: ClaseFactory.Clases) -> Button:
	var clase := ClaseFactory.crear_clase(tipo)
	var boton := Button.new()
	boton.text = "%s\n%s" % [clase.nombre, clase.describir()]
	boton.toggle_mode = true
	boton.button_group = _grupo_botones
	boton.pressed.connect(_on_card_pressed.bind(tipo))
	return boton

func _on_card_pressed(tipo: ClaseFactory.Clases) -> void:
	clase_seleccionada = tipo

func _on_comenzar() -> void:
	GameManager.seleccionar_clase(clase_seleccionada)
	GameManager.ir_a_combate()
	get_tree().change_scene_to_file("res://main_game.tscn")
