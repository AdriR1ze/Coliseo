class_name Player
extends CharacterBody3D

signal died(player: Player)

var id: int = 1
var arma: BaseArma = null
var _is_dancing: bool = false
var _is_dead: bool = false

@onready var health: Health = $Health
@onready var movement: Movement = $Movement
@onready var character_model: CharacterModel = $CharacterModel
@onready var habilidad_v: HabilidadV = $HabilidadV

func _ready() -> void:
	health.died.connect(_on_died)
	if character_model:
		character_model.play_idle()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_B:
			get_tree().call_group("dancers", "bailar")
		elif event.physical_keycode == KEY_V or event.keycode == KEY_V:
			ejecutar_v_command()

func ejecutar_v_command() -> void:
	if _is_dead:
		return
	if habilidad_v:
		var exito := habilidad_v.ejecutar(self)
		if exito and _is_dancing:
			detener_baile()

func bailar() -> void:
	if _is_dead:
		return
	_is_dancing = true
	if character_model:
		character_model.play_dance()

func detener_baile() -> void:
	_is_dancing = false

func _on_died() -> void:
	if _is_dead:
		return
	_is_dead = true
	_is_dancing = false
	movement.detener()
	movement.active = false
	remove_from_group("player")
	remove_from_group("dancers")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if character_model:
		character_model.play_dead()
	GameManager.ir_a_derrota()
	died.emit(self)

func aplicar_clase(clase: BaseClase) -> void:
	if clase == null:
		return
	movement.speed = clase.velocidad
	if health:
		health.max_health = clase.salud_maxima
		health.current_health = health.max_health
	if arma:
		arma.queue_free()
		arma = null
	arma = clase.crear_arma()
	if arma:
		add_child(arma)

func take_damage(amount: int) -> void:
	if _is_dead:
		return
	if health:
		health.take_damage(amount)

func _obtener_direccion_ataque() -> Vector3:
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return -global_transform.basis.z.normalized()
	var centro := get_viewport().get_visible_rect().size * 0.5
	var origen_rayo := camera.project_ray_origin(centro)
	var dir_rayo := camera.project_ray_normal(centro)
	var punto_objetivo := _obtener_punto_en_mira(origen_rayo, dir_rayo)
	var origen_disparo := global_position + Vector3(0, 1.2, 0)
	var dir := punto_objetivo - origen_disparo
	if dir.is_zero_approx():
		return dir_rayo
	return dir.normalized()

func _obtener_punto_en_mira(origen: Vector3, dir: Vector3) -> Vector3:
	var espacio := get_world_3d().direct_space_state
	var consulta := PhysicsRayQueryParameters3D.create(origen, origen + dir * 100.0)
	consulta.exclude = [get_rid()]
	var resultado := espacio.intersect_ray(consulta)
	if resultado:
		return resultado.position
	return origen + dir * 30.0

func _intentar_atacar() -> void:
	if _is_dead or arma == null:
		return
	if arma.puede_atacar():
		if _is_dancing:
			detener_baile()
		if character_model:
			character_model.play_attack()
		arma.atacar(self, _obtener_direccion_ataque())

func _physics_process(_delta: float) -> void:
	if _is_dead:
		return

	if Input.is_action_just_pressed("attack") or Input.is_action_pressed("attack"):
		_intentar_atacar()

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		movement.saltar()
		if _is_dancing:
			detener_baile()

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(-input_dir.x, 0, -input_dir.y)).normalized()
	
	if direction != Vector3.ZERO:
		if _is_dancing:
			detener_baile()
		movement.mover(direction)
		
		if character_model:
			if movement.speed > 5.5:
				character_model.play_run()
			else:
				character_model.play_walk()
	else:
		movement.frenar()
		
		if character_model and not _is_dancing:
			character_model.play_idle()
