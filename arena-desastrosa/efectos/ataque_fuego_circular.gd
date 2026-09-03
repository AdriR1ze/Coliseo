class_name AtaqueFuegoCircular
extends Node3D

@export var radio_maximo: float = 7.0
@export var dano: int = 60
@export var duracion_expansion: float = 0.6
@export var duracion_desvanecido: float = 0.5

@onready var area_impacto: Area3D = $AreaImpacto
@onready var forma_colision: CollisionShape3D = $AreaImpacto/CollisionShape3D
@onready var anillo: MeshInstance3D = $Anillo
@onready var disco_suelo: MeshInstance3D = $DiscoSuelo
@onready var cupula: MeshInstance3D = $Cupula
@onready var bola: MeshInstance3D = $Bola
@onready var luz: OmniLight3D = $Luz

var _enemigos_danados: Dictionary = {}

func _ready() -> void:
	if forma_colision and forma_colision.shape:
		forma_colision.shape = forma_colision.shape.duplicate()

func activar(emisor: Node3D) -> void:
	_iniciar_efecto_visual()
	_iniciar_dano_area(emisor)

func _iniciar_dano_area(_emisor: Node3D) -> void:
	var centro := global_position
	var enemigos := get_tree().get_nodes_in_group("enemies")
	for enemigo in enemigos:
		if not is_instance_valid(enemigo) or not (enemigo is Node3D):
			continue
		var dist := centro.distance_to((enemigo as Node3D).global_position)
		if dist <= radio_maximo:
			_danar_enemigo(enemigo)

func _danar_enemigo(enemigo: Node) -> void:
	var id := enemigo.get_instance_id()
	if _enemigos_danados.has(id):
		return
	_enemigos_danados[id] = true
	if enemigo.has_method("take_damage"):
		enemigo.take_damage(dano)

func _on_area_impacto_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemies"):
		_danar_enemigo(body)

func _iniciar_efecto_visual() -> void:
	# Escalas iniciales concentradas en el centro
	anillo.scale = Vector3(0.3, 1.0, 0.3)
	disco_suelo.scale = Vector3(0.3, 1.0, 0.3)
	cupula.scale = Vector3(0.3, 0.3, 0.3)
	bola.scale = Vector3(0.5, 0.5, 0.5)
	
	# Duplicar materiales para manipular opacidad individual
	var mat_anillo := anillo.get_active_material(0).duplicate() as StandardMaterial3D
	anillo.material_override = mat_anillo
	
	var mat_disco := disco_suelo.get_active_material(0).duplicate() as StandardMaterial3D
	disco_suelo.material_override = mat_disco
	
	var mat_cupula := cupula.get_active_material(0).duplicate() as StandardMaterial3D
	cupula.material_override = mat_cupula
	
	var mat_bola := bola.get_active_material(0).duplicate() as StandardMaterial3D
	bola.material_override = mat_bola

	# 1. FASE DE EXPANSIÓN CIRCULAR
	var tw_expand := create_tween().set_parallel(true)
	
	# Anillo horizontal expandiéndose por el suelo
	tw_expand.tween_property(anillo, "scale", Vector3(radio_maximo, 1.6, radio_maximo), duracion_expansion).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	# Disco de fuego llenando toda el área circular sobre el suelo
	tw_expand.tween_property(disco_suelo, "scale", Vector3(radio_maximo, 1.0, radio_maximo), duracion_expansion).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	# Cúpula de fuego 3D elevándose y abriéndose hacia afuera
	tw_expand.tween_property(cupula, "scale", Vector3(radio_maximo, radio_maximo * 0.45, radio_maximo), duracion_expansion).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw_expand.tween_property(mat_cupula, "albedo_color:a", 0.0, duracion_expansion * 0.85).set_delay(duracion_expansion * 0.15)
	
	# Bola de destello central inicial
	tw_expand.tween_property(bola, "scale", Vector3(2.5, 2.5, 2.5), 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw_expand.tween_property(mat_bola, "albedo_color:a", 0.0, 0.35)
	
	# Rango de iluminación
	tw_expand.tween_property(luz, "omni_range", radio_maximo * 1.5, duracion_expansion)
	
	# Chispas de fuego que salen eyectadas en círculo
	_crear_chispas_radiales()

	# 2. FASE DE DESVANECIMIENTO Y CIERRE
	var tw_fade := create_tween().set_parallel(true)
	# Espera un instante para que el área de fuego sea claramente visible en su tamaño completo
	tw_fade.tween_interval(duracion_expansion * 0.6)
	tw_fade.chain().tween_property(mat_anillo, "albedo_color:a", 0.0, duracion_desvanecido).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw_fade.parallel().tween_property(mat_disco, "albedo_color:a", 0.0, duracion_desvanecido).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw_fade.parallel().tween_property(luz, "light_energy", 0.0, duracion_desvanecido + 0.1)
	
	tw_fade.chain().tween_callback(queue_free)

func _crear_chispas_radiales() -> void:
	var num_chispas := 28
	var origen := global_position
	var parent := get_parent()
	if parent == null:
		parent = self
		
	for i in num_chispas:
		var angulo := TAU * float(i) / float(num_chispas)
		var dir := Vector3(cos(angulo), 0.0, sin(angulo))
		
		var chispa := MeshInstance3D.new()
		var s := SphereMesh.new()
		s.radius = 0.12
		s.height = 0.24
		chispa.mesh = s
		
		var mat_c := StandardMaterial3D.new()
		mat_c.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat_c.albedo_color = Color(1.0, 0.7, 0.2)
		mat_c.emission_enabled = true
		mat_c.emission = Color(1.0, 0.55, 0.1)
		mat_c.emission_energy_multiplier = 5.0
		chispa.material_override = mat_c
		
		parent.add_child(chispa)
		chispa.global_position = origen + Vector3(0, 0.3, 0)
		
		var dist_objetivo := radio_maximo * randf_range(0.85, 1.2)
		var destino := origen + dir * dist_objetivo
		destino.y += randf_range(0.1, 0.8)
		
		var dur := randf_range(0.45, 0.7)
		var tw := chispa.create_tween()
		tw.parallel().tween_property(chispa, "global_position", destino, dur).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(chispa, "scale", Vector3.ZERO, dur).set_delay(dur * 0.4)
		tw.chain().tween_callback(chispa.queue_free)
