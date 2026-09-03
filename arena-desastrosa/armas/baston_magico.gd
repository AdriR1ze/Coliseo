class_name BastonMagico
extends BaseArma

const PROYECTIL_SCRIPT = preload("res://armas/proyectil_magico.gd")

func _init() -> void:
	nombre = "Bastón Mágico"
	dano = 28
	cooldown = 0.6
	alcance = 25.0

func _ready() -> void:
	_crear_visual()

## Crea un mesh visible en la mano del personaje: un bastón de madera
## rematado por una gema mágica brillante.
func _crear_visual() -> void:
	var pivot := Node3D.new()
	# Posición aproximada de la mano derecha del personaje
	pivot.position = Vector3(0.35, 0.95, 0.4)
	pivot.rotation_degrees = Vector3(0.0, 0.0, 8.0)
	add_child(pivot)

	# Asta de madera
	var asta := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.03
	cyl.bottom_radius = 0.04
	cyl.height = 1.1
	asta.mesh = cyl
	var mat_asta := StandardMaterial3D.new()
	mat_asta.albedo_color = Color(0.35, 0.22, 0.12)
	mat_asta.roughness = 0.7
	asta.material_override = mat_asta
	asta.position = Vector3(0.0, 0.5, 0.0)
	pivot.add_child(asta)

	# Abrazadera metálica donde se sujeta la gema
	var anillo := MeshInstance3D.new()
	var toro := TorusMesh.new()
	toro.inner_radius = 0.045
	toro.outer_radius = 0.06
	toro.rings = 12
	toro.ring_segments = 16
	anillo.mesh = toro
	var mat_anillo := StandardMaterial3D.new()
	mat_anillo.albedo_color = Color(0.75, 0.7, 0.4)
	mat_anillo.metallic = 0.85
	mat_anillo.roughness = 0.25
	anillo.material_override = mat_anillo
	anillo.position = Vector3(0.0, 1.02, 0.0)
	pivot.add_child(anillo)

	# Gema mágica en la punta
	var gema := MeshInstance3D.new()
	var esfera := SphereMesh.new()
	esfera.radius = 0.12
	esfera.height = 0.24
	gema.mesh = esfera
	var mat_gema := StandardMaterial3D.new()
	mat_gema.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat_gema.albedo_color = Color(0.3, 0.7, 1.0)
	mat_gema.emission_enabled = true
	mat_gema.emission = Color(0.2, 0.6, 1.0)
	mat_gema.emission_energy_multiplier = 3.0
	gema.material_override = mat_gema
	gema.position = Vector3(0.0, 1.15, 0.0)
	pivot.add_child(gema)

	# Luz que emana de la gema
	var luz := OmniLight3D.new()
	luz.light_color = Color(0.3, 0.7, 1.0)
	luz.light_energy = 1.5
	luz.omni_range = 2.5
	luz.position = Vector3(0.0, 1.15, 0.0)
	pivot.add_child(luz)

func atacar(portador: Node3D, direccion: Vector3) -> bool:
	if not super.atacar(portador, direccion):
		return false
	
	var dir := direccion.normalized()
	if dir.is_zero_approx():
		dir = -portador.global_transform.basis.z.normalized()
		
	var proyectil_node := Area3D.new()
	proyectil_node.set_script(PROYECTIL_SCRIPT)
	var proyectil := proyectil_node as ProyectilMagico
	proyectil.direccion = dir
	proyectil.dano = dano
	
	var root := portador.get_parent()
	if root == null:
		root = portador
		
	var spawn_pos := portador.global_position + Vector3(0, 1.2, 0) + dir * 0.8
	root.add_child(proyectil)
	proyectil.global_position = spawn_pos
	return true
