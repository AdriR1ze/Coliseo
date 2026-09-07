extends Node

## Gestiona las oleadas: spawn de enemigos y conteo de vivos (patrón Observer vía señales).

signal oleada_iniciada(numero: int)
signal oleada_terminada(numero: int)
signal enemigo_eliminado(restantes: int)
signal enemigo_eliminado_total(total: int)

const COOLDOWN_SPAWN := 2.0

## Área de spawn: radio mínimo y máximo alrededor del spawn_root (modificable).
@export var radio_spawn_min: float = 12.0
@export var radio_spawn_max: float = 16.0
## Distancia mínima respecto al jugador para no spawnear a su lado.
@export var radio_seguro_default: float = 6.0
@export var intentos_spawn: int = 12

var oleada_actual: int = 0
var enemigos_vivos: int = 0
var total_eliminados: int = 0

func iniciar_oleada(spawn_root: Node3D, numero: int, cantidad: int) -> void:
	oleada_actual = numero
	enemigos_vivos = cantidad
	oleada_iniciada.emit(numero)
	await get_tree().create_timer(COOLDOWN_SPAWN).timeout
	for i in cantidad:
		_spawn_enemigo(spawn_root, EnemyFactory.TipoEnemigo.BASICO)

func _spawn_enemigo(spawn_root: Node3D, tipo: EnemyFactory.TipoEnemigo) -> void:
	var enemigo := EnemyFactory.crear_enemigo(tipo)
	if enemigo == null:
		return
	spawn_root.add_child(enemigo)
	enemigo.global_position = _obtener_posicion_spawn(spawn_root)
	enemigo.died.connect(_on_enemigo_muerto)

## Calcula una posición de spawn dentro del área y lejos del jugador.
func _obtener_posicion_spawn(spawn_root: Node3D) -> Vector3:
	var jugador := _obtener_jugador()
	var radio_seguro := _obtener_radio_seguro(jugador)
	for _i in intentos_spawn:
		var angle := randf_range(0.0, TAU)
		var radius := randf_range(radio_spawn_min, radio_spawn_max)
		var offset := Vector3(cos(angle) * radius, 0.0, sin(angle) * radius)
		var pos := spawn_root.global_position + offset
		if jugador == null or pos.distance_to(jugador.global_position) >= radio_seguro:
			return pos
	return spawn_root.global_position

func _obtener_jugador() -> Node3D:
	for p in get_tree().get_nodes_in_group("player"):
		if p is Node3D:
			return p
	return null

## Lee el radio del área segura del jugador (ZonaSegura), modificable en la escena.
func _obtener_radio_seguro(jugador: Node3D) -> float:
	if jugador == null:
		return radio_seguro_default
	var shape_node := jugador.get_node_or_null("ZonaSegura/CollisionShape3D")
	if shape_node and shape_node.shape is SphereShape3D:
		return (shape_node.shape as SphereShape3D).radius
	return radio_seguro_default

func _on_enemigo_muerto(_enemigo: Enemy) -> void:
	enemigos_vivos = maxi(0, enemigos_vivos - 1)
	total_eliminados += 1
	enemigo_eliminado.emit(enemigos_vivos)
	enemigo_eliminado_total.emit(total_eliminados)
	if enemigos_vivos == 0:
		oleada_terminada.emit(oleada_actual)
