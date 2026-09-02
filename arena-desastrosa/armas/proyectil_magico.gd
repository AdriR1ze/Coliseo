class_name ProyectilMagico
extends Area3D

@export var velocidad: float = 24.0
@export var dano: int = 30
@export var tiempo_vida: float = 3.0

var direccion: Vector3 = Vector3.FORWARD
var _tiempo_vivo: float = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_crear_visuales()

func _crear_visuales() -> void:
	var mesh_inst := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.25
	sphere.height = 0.5
	mesh_inst.mesh = sphere
	
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(0.2, 0.7, 1.0, 1.0)
	mat.emission_enabled = true
	mat.emission = Color(0.1, 0.6, 1.0)
	mat.emission_energy_multiplier = 4.0
	mesh_inst.material_override = mat
	add_child(mesh_inst)
	
	var light := OmniLight3D.new()
	light.light_color = Color(0.2, 0.7, 1.0)
	light.light_energy = 2.0
	light.omni_range = 3.5
	add_child(light)
	
	var col := CollisionShape3D.new()
	var sphere_shape := SphereShape3D.new()
	sphere_shape.radius = 0.3
	col.shape = sphere_shape
	add_child(col)

func _physics_process(delta: float) -> void:
	global_position += direccion * velocidad * delta
	_tiempo_vivo += delta
	if _tiempo_vivo >= tiempo_vida:
		queue_free()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		return
	if body.has_method("take_damage"):
		body.take_damage(dano)
		_crear_impacto()
		queue_free()
	elif not (body is Area3D):
		_crear_impacto()
		queue_free()

func _crear_impacto() -> void:
	var burst := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.35
	sphere.height = 0.7
	burst.mesh = sphere
	
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(0.4, 0.8, 1.0, 0.9)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color(0.4, 0.8, 1.0)
	mat.emission_energy_multiplier = 3.0
	burst.material_override = mat
	
	var parent := get_parent()
	if parent == null:
		return
	parent.add_child(burst)
	burst.global_position = global_position
	
	var tween := burst.create_tween()
	tween.tween_property(burst, "scale", Vector3(2.5, 2.5, 2.5), 0.15)
	tween.parallel().tween_property(mat, "albedo_color:a", 0.0, 0.15)
	tween.tween_callback(burst.queue_free)
