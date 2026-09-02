class_name DecoradorVeneno
extends DecoradorArma

## Decorator – Veneno
## Aplica daño por tiempo (DoT) a todo enemigo golpeado por el arma interna.
## Se apila con otros decoradores normalmente.

@export var dano_veneno: int = 5          # daño por tick
@export var ticks: int = 4                # cuántas veces aplica
@export var intervalo: float = 1.0        # segundos entre ticks
@export var color_veneno: Color = Color(0.3, 1.0, 0.2, 0.75)

func _init() -> void:
	nombre = "Veneno"

func _on_ataque_decorado(portador: Node3D, _direccion: Vector3) -> void:
	# Busca todos los enemigos que el arma interna podría haber golpeado
	# (usamos el mismo radio/grupo que las armas concretas usan).
	var enemigos := portador.get_tree().get_nodes_in_group("enemies")
	for enemigo in enemigos:
		if not is_instance_valid(enemigo) or not (enemigo is Node3D):
			continue
		var dist: float = portador.global_position.distance_to(
				(enemigo as Node3D).global_position)
		if dist <= alcance + 0.5:   # pequeña tolerancia
			_aplicar_veneno(enemigo)

func _aplicar_veneno(objetivo: Node) -> void:
	if not is_instance_valid(objetivo):
		return
	# Lanzar coroutine de DoT desde el SceneTree del objetivo.
	var tree := objetivo.get_tree()
	if tree == null:
		return
	_dot_loop(objetivo, tree)

func _dot_loop(objetivo: Node, tree: SceneTree) -> void:
	_crear_efecto_inicial(objetivo as Node3D)
	for i in ticks:
		await tree.create_timer(intervalo).timeout
		if not is_instance_valid(objetivo):
			return
		if objetivo.has_method("take_damage"):
			objetivo.take_damage(dano_veneno)
			_crear_tick_visual(objetivo as Node3D)

func _crear_efecto_inicial(objetivo: Node3D) -> void:
	var burst := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.5
	sphere.height = 1.0
	burst.mesh = sphere
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = color_veneno
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = color_veneno
	mat.emission_energy_multiplier = 1.5
	burst.material_override = mat
	var root := objetivo.get_parent()
	if root == null:
		return
	root.add_child(burst)
	burst.global_position = objetivo.global_position + Vector3(0, 0.8, 0)
	var tween := burst.create_tween()
	tween.tween_property(burst, "scale", Vector3(1.5, 1.5, 1.5), 0.2)
	tween.parallel().tween_property(mat, "albedo_color:a", 0.0, 0.3)
	tween.tween_callback(burst.queue_free)

func _crear_tick_visual(objetivo: Node3D) -> void:
	if not is_instance_valid(objetivo):
		return
	var pip := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.12
	sphere.height = 0.24
	pip.mesh = sphere
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = color_veneno
	mat.emission_enabled = true
	mat.emission = color_veneno
	mat.emission_energy_multiplier = 2.0
	pip.material_override = mat
	var root := objetivo.get_parent()
	if root == null:
		return
	root.add_child(pip)
	pip.global_position = objetivo.global_position + Vector3(
			randf_range(-0.4, 0.4), randf_range(0.4, 1.2), randf_range(-0.4, 0.4))
	var tween := pip.create_tween()
	tween.tween_property(pip, "global_position",
			pip.global_position + Vector3(0, 0.6, 0), 0.4)
	tween.parallel().tween_property(pip, "scale", Vector3.ZERO, 0.4)
	tween.tween_callback(pip.queue_free)
