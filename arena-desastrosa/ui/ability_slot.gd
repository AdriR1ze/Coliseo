class_name AbilitySlot
extends Control

@onready var icono: TextureRect = $Icono
@onready var fondo_opaco: ColorRect = $FondoOpaco
@onready var barra_progreso: ProgressBar = $BarraProgreso
@onready var label_tiempo: Label = $LabelTiempo
@onready var label_tecla: Label = $LabelTecla

var _habilidad: HabilidadV = null

func _ready() -> void:
	marcar_lista()

func setup(habilidad: HabilidadV) -> void:
	_habilidad = habilidad
	if _habilidad == null:
		return
	
	if not _habilidad.cooldown_iniciado.is_connected(_on_cooldown_iniciado):
		_habilidad.cooldown_iniciado.connect(_on_cooldown_iniciado)
	if not _habilidad.cooldown_actualizado.is_connected(_on_cooldown_actualizado):
		_habilidad.cooldown_actualizado.connect(_on_cooldown_actualizado)
	if not _habilidad.cooldown_finalizado.is_connected(_on_cooldown_finalizado):
		_habilidad.cooldown_finalizado.connect(_on_cooldown_finalizado)
		
	if _habilidad.puede_usarse():
		marcar_lista()
	else:
		marcar_en_cooldown(_habilidad.cooldown_duracion)

func marcar_lista() -> void:
	if fondo_opaco:
		fondo_opaco.visible = false
	if label_tiempo:
		label_tiempo.visible = false
	if barra_progreso:
		barra_progreso.value = barra_progreso.max_value

func marcar_en_cooldown(duracion: float) -> void:
	if fondo_opaco:
		fondo_opaco.visible = true
	if label_tiempo:
		label_tiempo.visible = true
		label_tiempo.text = "%.1fs" % duracion
	if barra_progreso:
		barra_progreso.max_value = duracion
		barra_progreso.value = 0.0

func _on_cooldown_iniciado(duracion: float) -> void:
	marcar_en_cooldown(duracion)

func _on_cooldown_actualizado(tiempo_restante: float, duracion: float) -> void:
	if fondo_opaco:
		fondo_opaco.visible = true
	if label_tiempo:
		label_tiempo.visible = true
		label_tiempo.text = "%.1fs" % tiempo_restante
	if barra_progreso:
		var cargado := duracion - tiempo_restante
		barra_progreso.max_value = duracion
		barra_progreso.value = cargado

func _on_cooldown_finalizado() -> void:
	marcar_lista()
