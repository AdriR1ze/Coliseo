class_name DecoradorFuego
extends DecoradorArma

## Decorator – Fuego
## Añade daño extra de fuego a cada ataque del arma interna
## y produce una bola de fuego visual en el punto de impacto.

@export var dano_fuego: int = 12
@export var color_fuego: Color = Color(1.0, 0.45, 0.1, 0.9)

func _init() -> void:
	nombre = "Fuego"

func _on_ataque_decorado(portador: Node3D, _direccion: Vector3) -> void:
	var enemigos := portador.get_tree().get_nodes_in_group("enemies")
	for enemigo in enemigos:
		if not is_instance_valid(enemigo) or not (enemigo is Node3D):
			continue
		var dist: float = portador.global_position.distance_to(
				(enemigo as Node3D).global_position)
		if dist <= alcance + 0.5:
			if enemigo.has_method("take_damage"):
				enemigo.take_damage(dano_fuego)
			_crear_explosion_fuego(enemigo as Node3D)

func _crear_explosion_fuego(objetivo: Node3D) -> void:
	if not is_instance_valid(objetivo):
		return
	var root := objetivo.get_parent()
	if root == null:
		return

	# Bola de fuego central
	var bola := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.4
	sphere.height = 0.8
	bola.mesh = sphere
	var mat_bola := StandardMaterial3D.new()
	mat_bola.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat_bola.albedo_color = color_fuego
	mat_bola.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat_bola.emission_enabled = true
	mat_bola.emission = color_fuego
	mat_bola.emission_energy_multiplier = 5.0
	bola.material_override = mat_bola
	root.add_child(bola)
	bola.global_position = objetivo.global_position + Vector3(0, 0.9, 0)

	# Luz puntual
	var light := OmniLight3D.new()
	light.light_color = Color(1.0, 0.5, 0.1)
	light.light_energy = 4.0
	light.omni_range = 4.0
	root.add_child(light)
	light.global_position = bola.global_position

	# Tween: expansión + desvanecimiento
	var tween := bola.create_tween().set_parallel(true)
	tween.tween_property(bola, "scale", Vector3(2.5, 2.5, 2.5), 0.25)
	tween.tween_property(mat_bola, "albedo_color:a", 0.0, 0.25)
	tween.tween_property(light, "light_energy", 0.0, 0.3)
	tween.set_parallel(false)
	tween.tween_callback(bola.queue_free)
	tween.tween_callback(light.queue_free)

	# Chispas ascendentes
	for i in 6:
		var chispa := MeshInstance3D.new()
		var s := SphereMesh.new()
		s.radius = 0.07
		s.height = 0.14
		chispa.mesh = s
		var mat_c := StandardMaterial3D.new()
		mat_c.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat_c.albedo_color = Color(1.0, 0.8, 0.2)
		mat_c.emission_enabled = true
		mat_c.emission = Color(1.0, 0.7, 0.1)
		mat_c.emission_energy_multiplier = 3.0
		chispa.material_override = mat_c
		root.add_child(chispa)
		chispa.global_position = bola.global_position + Vector3(
				randf_range(-0.3, 0.3), 0.0, randf_range(-0.3, 0.3))
		var destino := chispa.global_position + Vector3(
				randf_range(-0.5, 0.5), randf_range(0.8, 1.6), randf_range(-0.5, 0.5))
		var tw2 := chispa.create_tween()
		tw2.tween_property(chispa, "global_position", destino, randf_range(0.3, 0.5))
		tw2.parallel().tween_property(chispa, "scale", Vector3.ZERO, randf_range(0.3, 0.5))
		tw2.tween_callback(chispa.queue_free)
