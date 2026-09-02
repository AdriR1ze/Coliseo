class_name HUD
extends Control

var label_vida: Label
var label_clase: Label
var label_arma: Label
var panel_derrota: CenterContainer
var player: Player = null

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build()

func _build() -> void:
	# Panel de información superior izquierda
	var margin_top_left := MarginContainer.new()
	margin_top_left.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	margin_top_left.add_theme_constant_override("margin_left", 20)
	margin_top_left.add_theme_constant_override("margin_top", 20)
	margin_top_left.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(margin_top_left)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin_top_left.add_child(vbox)

	label_clase = Label.new()
	label_clase.add_theme_font_size_override("font_size", 18)
	vbox.add_child(label_clase)

	label_arma = Label.new()
	label_arma.add_theme_font_size_override("font_size", 16)
	vbox.add_child(label_arma)

	label_vida = Label.new()
	label_vida.add_theme_font_size_override("font_size", 18)
	vbox.add_child(label_vida)

	# Pantalla de derrota centrada
	_build_pantalla_derrota()

func _build_pantalla_derrota() -> void:
	panel_derrota = CenterContainer.new()
	panel_derrota.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel_derrota.visible = false
	panel_derrota.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(panel_derrota)

	# Fondo oscuro
	var fondo_panel := PanelContainer.new()
	panel_derrota.add_child(fondo_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 40)
	margin.add_theme_constant_override("margin_right", 40)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_bottom", 30)
	fondo_panel.add_child(margin)

	var vbox_derrota := VBoxContainer.new()
	vbox_derrota.add_theme_constant_override("separation", 18)
	vbox_derrota.alignment = BoxContainer.ALIGNMENT_CENTER
	margin.add_child(vbox_derrota)

	var titulo := Label.new()
	titulo.text = "¡HAS MUERTO!"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_font_size_override("font_size", 32)
	titulo.add_theme_color_override("font_color", Color(1.0, 0.25, 0.25))
	vbox_derrota.add_child(titulo)

	var subtitulo := Label.new()
	subtitulo.text = "Los enemigos han acabado contigo en la arena."
	subtitulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitulo.add_theme_font_size_override("font_size", 16)
	vbox_derrota.add_child(subtitulo)

	var btn_reintentar := Button.new()
	btn_reintentar.text = "Reintentar Partida"
	btn_reintentar.custom_minimum_size = Vector2(220, 42)
	btn_reintentar.pressed.connect(_on_reintentar_pressed)
	vbox_derrota.add_child(btn_reintentar)

	var btn_cambiar_clase := Button.new()
	btn_cambiar_clase.text = "Cambiar de Clase"
	btn_cambiar_clase.custom_minimum_size = Vector2(220, 42)
	btn_cambiar_clase.pressed.connect(_on_cambiar_clase_pressed)
	vbox_derrota.add_child(btn_cambiar_clase)

func setup(jugador: Player) -> void:
	player = jugador
	var clase := ClassManager.get_class_player(jugador)
	if clase:
		label_clase.text = "Clase: %s" % clase.nombre
	_actualizar_label_arma(jugador)
	label_vida.text = "Vida: %d / %d" % [jugador.health.current_health, jugador.health.max_health]
	jugador.health.health_changed.connect(_on_health_changed)
	jugador.health.died.connect(_on_player_died)

func _actualizar_label_arma(jugador: Player) -> void:
	if jugador.arma == null:
		label_arma.text = ""
		return
	var arma := jugador.arma
	var nombre_mostrar: String
	if arma is DecoradorArma:
		nombre_mostrar = (arma as DecoradorArma).get_nombre_completo()
	else:
		nombre_mostrar = arma.nombre
	label_arma.text = "Arma: %s (Daño: %d)" % [nombre_mostrar, arma.dano]


func _on_health_changed(current: int, max_health: int) -> void:
	label_vida.text = "Vida: %d / %d" % [current, max_health]
	if current <= max_health * 0.3:
		label_vida.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
	else:
		label_vida.remove_theme_color_override("font_color")

func _on_player_died() -> void:
	panel_derrota.visible = true

func _on_reintentar_pressed() -> void:
	GameManager.ir_a_combate()
	get_tree().reload_current_scene()

func _on_cambiar_clase_pressed() -> void:
	GameManager.ir_a_seleccion_clase()
	get_tree().change_scene_to_file("res://ui/class_select.tscn")
