extends Node

const PLAYER_SCENE := preload("res://player.tscn")
const LEVEL_1 := preload("res://level_1.tscn")

@onready var level_root: Node3D = %LevelRoot
@onready var entity_root: Node3D = %EntityRoot
@onready var hud: HUD = $HudLayer/HudRoot
@onready var ability_slot: AbilitySlot = %AbilitySlot

func _ready() -> void:
	_setup_lighting()
	_cargar_nivel.call_deferred(LEVEL_1)
	var jugador := init_player()
	hud.setup(jugador)
	if ability_slot and jugador.habilidad_v:
		ability_slot.setup(jugador.habilidad_v)
	WaveManager.iniciar_oleada(entity_root, 1, 5)

func _setup_lighting() -> void:
	var world := $World

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, -30, 0)
	sun.shadow_enabled = true
	sun.light_energy = 1.2
	world.add_child(sun)

	var world_env := WorldEnvironment.new()
	var environment := Environment.new()
	
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.35, 0.55, 0.85)
	sky_mat.sky_horizon_color = Color(0.65, 0.75, 0.85)
	sky_mat.ground_bottom_color = Color(0.2, 0.2, 0.25)
	sky_mat.ground_horizon_color = Color(0.55, 0.65, 0.75)
	
	var sky := Sky.new()
	sky.sky_material = sky_mat
	
	environment.background_mode = Environment.BG_SKY
	environment.sky = sky
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	environment.ambient_light_energy = 0.8
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	
	world_env.environment = environment
	world.add_child(world_env)

func _cargar_nivel(nivel: PackedScene) -> void:
	level_root.add_child(nivel.instantiate())

func init_player() -> Player:
	var jugador := PLAYER_SCENE.instantiate() as Player
	entity_root.add_child(jugador)
	jugador.global_position = Vector3(0, 1, 0)
	var clase := ClaseFactory.crear_clase(GameManager.clase_seleccionada)
	jugador.aplicar_clase(clase)
	ClassManager.ingresar_clase_player(jugador, GameManager.clase_seleccionada)
	return jugador
