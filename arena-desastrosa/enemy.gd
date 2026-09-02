class_name Enemy
extends CharacterBody3D

signal died(enemy: Enemy)

@export var speed: float = 1.5
const JUMP_VELOCITY = 4.5

var player: CharacterBody3D = null
var health: Health = null
var _is_dancing: bool = false
var _is_dead: bool = false

@onready var character_model: CharacterModel = $CharacterModel

func _ready() -> void:
	add_to_group("enemies")
	add_to_group("dancers")
	
	health = Health.new()
	health.max_health = 30
	add_child(health)
	health.died.connect(_on_died)
	
	_setup_contact_damage()
	if character_model:
		character_model.play_idle()
	_find_nearest_player()

func _setup_contact_damage() -> void:
	var contacto := ContactDamage.new()
	contacto.damage = 10
	contacto.cooldown = 1.0
	contacto.attack_range = 1.5
	add_child(contacto)

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
	velocity = Vector3.ZERO
	if character_model:
		character_model.play_dead()
	died.emit(self)
	
	var timer := get_tree().create_timer(1.2)
	timer.timeout.connect(queue_free)

func take_damage(amount: int) -> void:
	if _is_dead:
		return
	if health:
		health.take_damage(amount)

func _find_nearest_player() -> void:
	var players := get_tree().get_nodes_in_group("player")
	var min_dist := INF
	for p in players:
		if p is Node3D:
			var dist := global_position.distance_to(p.global_position)
			if dist < min_dist:
				min_dist = dist
				player = p

func _physics_process(delta: float) -> void:
	if _is_dead:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	if _is_dancing:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		move_and_slide()
		return

	if player == null or not is_instance_valid(player) or not player.is_in_group("player") or player.get("_is_dead") == true:
		player = null
		_find_nearest_player()
		if player == null:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
			if character_model:
				character_model.play_idle()
			move_and_slide()
			return

	var diff := player.global_position - global_position
	var flat := Vector3(diff.x, 0, diff.z)
	
	if flat.length() > 0.3:
		var dir := flat.normalized()
		look_at(global_position - flat, Vector3.UP)
		velocity.x = dir.x * speed
		velocity.z = dir.z * speed
		if character_model:
			character_model.play_walk()
	else:
		velocity.x = 0
		velocity.z = 0
		if character_model:
			character_model.play_idle()

	move_and_slide()
