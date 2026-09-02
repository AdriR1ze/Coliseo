class_name Espada
extends BaseArma

@export var angulo_ataque_deg: float = 120.0

func _init() -> void:
	nombre = "Espada"
	dano = 35
	cooldown = 0.45
	alcance = 2.8

func _ready() -> void:
	_crear_visual()

## Crea un mesh visible en la mano del personaje (hoja de espada).
## El nodo arma ya es hijo del Player en (0,0,0), así que
## desplazamos el mesh para que quede a la altura y posición de la mano.
func _crear_visual() -> void:
	var pivot := Node3D.new()
	# Posición aproximada de la mano derecha del personaje
	# (desplazamiento local desde el origen del Player)
	pivot.position = Vector3(0.35, 1.0, 0.4)
	pivot.rotation_degrees = Vector3(0.0, 0.0, -15.0)
	add_child(pivot)

	# Hoja
	var hoja := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.06, 0.85, 0.04)
	hoja.mesh = box
	var mat_hoja := StandardMaterial3D.new()
	mat_hoja.albedo_color = Color(0.75, 0.85, 0.95)
	mat_hoja.metallic = 0.9
	mat_hoja.roughness = 0.15
	hoja.material_override = mat_hoja
	pivot.add_child(hoja)

	# Guardia (crossguard)
	var guardia := MeshInstance3D.new()
	var gbox := BoxMesh.new()
	gbox.size = Vector3(0.3, 0.05, 0.07)
	guardia.mesh = gbox
	var mat_g := StandardMaterial3D.new()
	mat_g.albedo_color = Color(0.6, 0.5, 0.2)
	mat_g.metallic = 0.7
	mat_g.roughness = 0.3
	guardia.material_override = mat_g
	guardia.position = Vector3(0.0, -0.38, 0.0)
	pivot.add_child(guardia)

	# Mango
	var mango := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.025
	cyl.bottom_radius = 0.025
	cyl.height = 0.22
	mango.mesh = cyl
	var mat_m := StandardMaterial3D.new()
	mat_m.albedo_color = Color(0.35, 0.2, 0.1)
	mat_m.roughness = 0.8
	mango.material_override = mat_m
	mango.position = Vector3(0.0, -0.52, 0.0)
	pivot.add_child(mango)

func atacar(portador: Node3D, direccion: Vector3) -> bool:
	if not super.atacar(portador, direccion):
		return false
	
	_crear_efecto_corte(portador)
	_aplicar_dano_area(portador, direccion)
	return true

func _aplicar_dano_area(portador: Node3D, direccion: Vector3) -> void:
	var flat_dir := Vector3(direccion.x, 0, direccion.z).normalized()
	if flat_dir.is_zero_approx():
		flat_dir = -portador.global_transform.basis.z.normalized()
		
	var enemigos := portador.get_tree().get_nodes_in_group("enemies")
	var cos_max := cos(deg_to_rad(angulo_ataque_deg * 0.5))
	
	for enemigo in enemigos:
		if not is_instance_valid(enemigo) or not (enemigo is Node3D):
			continue
		var to_enemy: Vector3 = enemigo.global_position - portador.global_position
		var dist := to_enemy.length()
		if dist > alcance:
			continue
		var dir_to_enemy := Vector3(to_enemy.x, 0, to_enemy.z).normalized()
		if flat_dir.dot(dir_to_enemy) >= cos_max or dist < 1.0:
			if enemigo.has_method("take_damage"):
				enemigo.take_damage(dano)

func _crear_efecto_corte(portador: Node3D) -> void:
	var slash := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 1.0
	torus.outer_radius = 1.8
	torus.rings = 16
	torus.ring_segments = 16
	
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(1.0, 0.85, 0.3, 0.8)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.8, 0.2)
	mat.emission_energy_multiplier = 2.0
	slash.mesh = torus
	slash.material_override = mat
	
	var root := portador.get_parent()
	if root == null:
		root = portador
	root.add_child(slash)
	slash.global_position = portador.global_position + Vector3(0, 0.9, 0) - portador.global_transform.basis.z * 1.0
	slash.rotation = portador.rotation
	slash.scale = Vector3(1.2, 0.15, 1.2)
	
	var tween := slash.create_tween()
	tween.tween_property(slash, "scale", Vector3(1.8, 0.05, 1.8), 0.15)
	tween.parallel().tween_property(mat, "albedo_color:a", 0.0, 0.15)
	tween.tween_callback(slash.queue_free)
