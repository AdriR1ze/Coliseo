extends Node

## Gestiona las oleadas: spawn de enemigos y conteo de vivos (patrón Observer vía señales).

signal oleada_iniciada(numero: int)
signal oleada_terminada(numero: int)
signal enemigo_eliminado(restantes: int)

const COOLDOWN_SPAWN := 2.0

var oleada_actual: int = 0
var enemigos_vivos: int = 0

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
	var angle := randf_range(0.0, TAU)
	var radius := randf_range(12.0, 16.0)
	var offset := Vector3(cos(angle) * radius, 0.0, sin(angle) * radius)
	enemigo.global_position = spawn_root.global_position + offset
	enemigo.died.connect(_on_enemigo_muerto)

func _on_enemigo_muerto(_enemigo: Enemy) -> void:
	enemigos_vivos = maxi(0, enemigos_vivos - 1)
	enemigo_eliminado.emit(enemigos_vivos)
	if enemigos_vivos == 0:
		oleada_terminada.emit(oleada_actual)
