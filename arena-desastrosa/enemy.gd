class_name Enemy
extends CharacterBody3D

signal died(enemy: Enemy)

var player: CharacterBody3D = null
var _is_dancing: bool = false
var _is_dead: bool = false

@onready var health: Health = $Health
@onready var movement: Movement = $Movement
@onready var character_model: CharacterModel = $CharacterModel

func _ready() -> void:
	health.died.connect(_on_died)
	if character_model:
		character_model.play_idle()
	_find_nearest_player()

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

func _physics_process(_delta: float) -> void:
	if _is_dead:
		return

	if _is_dancing:
		movement.frenar()
		return

	if player == null or not is_instance_valid(player) or not player.is_in_group("player") or player.get("_is_dead") == true:
		player = null
		_find_nearest_player()
		if player == null:
			movement.frenar()
			if character_model:
				character_model.play_idle()
			return

	var diff := player.global_position - global_position
	var flat := Vector3(diff.x, 0, diff.z)
	
	if flat.length() > 0.3:
		var dir := flat.normalized()
		look_at(global_position - flat, Vector3.UP)
		movement.mover(dir)
		if character_model:
			character_model.play_walk()
	else:
		movement.frenar()
		if character_model:
			character_model.play_idle()
