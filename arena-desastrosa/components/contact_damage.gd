class_name ContactDamage
extends Node

@export var damage: int = 10
@export var cooldown: float = 1.0
@export var attack_range: float = 1.5

var body: Node3D
var _cooldown := 0.0

func _ready() -> void:
	body = get_parent()

func _physics_process(delta: float) -> void:
	_cooldown = maxf(0.0, _cooldown - delta)
	if _cooldown > 0.0:
		return
	var objetivo := _encontrar_objetivo()
	if objetivo == null or body == null:
		return
	if body.global_position.distance_to(objetivo.global_position) > attack_range:
		return
	if objetivo.has_method("take_damage"):
		objetivo.take_damage(damage)
		_cooldown = cooldown

func _encontrar_objetivo() -> Node3D:
	var players = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return null
	var target: Node3D = players[0]
	if target.get("_is_dead") == true:
		return null
	return target
