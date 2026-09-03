class_name ExplosionFuego
extends BaseArma

## Ataque de área: explosión de fuego que nace del centro del personaje
## y se expande de forma circular hacia afuera, dañando a todos los
## enemigos dentro del radio (alcance).

func _init() -> void:
	nombre = "Explosión de Fuego"
	dano = 45
	cooldown = 1.6
	alcance = 4.0

func atacar(portador: Node3D, _direccion: Vector3) -> bool:
	if not super.atacar(portador, _direccion):
		return false
	_aplicar_dano_area(portador)
	_crear_efecto_explosion(portador)
	return true

## Daña a todos los enemigos dentro del radio de la explosión.
func _aplicar_dano_area(portador: Node3D) -> void:
	var centro := portador.global_position
	var enemigos := portador.get_tree().get_nodes_in_group("enemies")
	for enemigo in enemigos:
		if not is_instance_valid(enemigo) or not (enemigo is Node3D):
			continue
		if centro.distance_to((enemigo as Node3D).global_position) <= alcance:
			if enemigo.has_method("take_damage"):
				enemigo.take_damage(dano)

## Efecto visual: anillo de fuego que se expande en círculo desde el
## centro del personaje, más una bola de fuego, luz y chispas radiales.
func _crear_efecto_explosion(portador: Node3D) -> void:
	var root := portador.get_parent()
	if root == null:
		root = portador
	var origen := portador.global_position + Vector3(0, 0.9, 0)

	# Anillo de fuego que se expande de forma circular
	var anillo := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 0.85
	torus.outer_radius = 1.0
	torus.rings = 24
	torus.ring_segments = 48
	anillo.mesh = torus
	var mat_anillo := StandardMaterial3D.new()
	mat_anillo.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat_anillo.albedo_color = Color(1.0, 0.5, 0.1, 0.9)
	mat_anillo.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat_anillo.emission_enabled = true
	mat_anillo.emission = Color(1.0, 0.4, 0.05)
	mat_anillo.emission_energy_multiplier = 4.0
	anillo.material_override = mat_anillo
	anillo.rotation_degrees = Vector3(90, 0, 0)
	root.add_child(anillo)
	anillo.global_position = origen

	# Bola de fuego central
	var bola := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.5
	sphere.height = 1.0
	bola.mesh = sphere
	var mat_bola := StandardMaterial3D.new()
	mat_bola.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat_bola.albedo_color = Color(1.0, 0.6, 0.2, 0.95)
	mat_bola.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat_bola.emission_enabled = true
	mat_bola.emission = Color(1.0, 0.45, 0.1)
	mat_bola.emission_energy_multiplier = 5.0
	bola.material_override = mat_bola
	root.add_child(bola)
	bola.global_position = origen

	# Luz de la explosión
	var luz := OmniLight3D.new()
	luz.light_color = Color(1.0, 0.5, 0.1)
	luz.light_energy = 6.0
	luz.omni_range = alcance * 1.5
	root.add_child(luz)
	luz.global_position = origen

	# Expansión + desvanecimiento
	var tween := anillo.create_tween().set_parallel(true)
	tween.tween_property(anillo, "scale", Vector3(alcance, alcance, alcance), 0.35)
	tween.tween_property(mat_anillo, "albedo_color:a", 0.0, 0.35)
	tween.tween_property(bola, "scale", Vector3(alcance * 0.5, alcance * 0.5, alcance * 0.5), 0.3)
	tween.tween_property(mat_bola, "albedo_color:a", 0.0, 0.3)
	tween.tween_property(luz, "light_energy", 0.0, 0.4)
	tween.set_parallel(false)
	tween.tween_callback(anillo.queue_free)
	tween.tween_callback(bola.queue_free)
	tween.tween_callback(luz.queue_free)

	# Chispas que salen disparadas radialmente hacia afuera
	for i in 16:
		var angulo := TAU * float(i) / 16.0
		var dir := Vector3(cos(angulo), 0, sin(angulo))
		var chispa := MeshInstance3D.new()
		var s := SphereMesh.new()
		s.radius = 0.06
		s.height = 0.12
		chispa.mesh = s
		var mat_c := StandardMaterial3D.new()
		mat_c.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat_c.albedo_color = Color(1.0, 0.7, 0.2)
		mat_c.emission_enabled = true
		mat_c.emission = Color(1.0, 0.6, 0.1)
		mat_c.emission_energy_multiplier = 3.0
		chispa.material_override = mat_c
		root.add_child(chispa)
		chispa.global_position = origen
		var destino := origen + dir * alcance * randf_range(0.8, 1.1)
		destino.y += randf_range(0.0, 0.6)
		var tw := chispa.create_tween()
		tw.tween_property(chispa, "global_position", destino, randf_range(0.25, 0.4))
		tw.parallel().tween_property(chispa, "scale", Vector3.ZERO, randf_range(0.25, 0.4))
		tw.tween_callback(chispa.queue_free)
