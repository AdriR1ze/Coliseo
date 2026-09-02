class_name CharacterModel
extends Node3D

const ANIM_IDLE := "idle"
const ANIM_WALK := "walking"
const ANIM_RUN := "running"
const ANIM_DANCE := "boom_dance"
const ANIM_ATTACK := "attack"
const ANIM_DEAD := "dead"

@onready var animation_player: AnimationPlayer = _find_animation_player()

func _ready() -> void:
	_configurar_loops()

func _configurar_loops() -> void:
	if animation_player == null:
		return
	for anim in animation_player.get_animation_list():
		var a := animation_player.get_animation(anim)
		if anim in [ANIM_IDLE, ANIM_WALK, ANIM_RUN, ANIM_DANCE]:
			a.loop_mode = Animation.LOOP_LINEAR

func _find_animation_player() -> AnimationPlayer:
	var ap := get_node_or_null("AnimationPlayer") as AnimationPlayer
	if ap:
		return ap
	var root := get_node_or_null("ModelRoot")
	if root:
		return root.get_node_or_null("AnimationPlayer") as AnimationPlayer
	return null

func is_attacking() -> bool:
	return animation_player != null and animation_player.is_playing() and animation_player.current_animation == ANIM_ATTACK

func is_dead() -> bool:
	return animation_player != null and animation_player.current_animation == ANIM_DEAD

func play_idle() -> void:
	if is_dead() or is_attacking():
		return
	_play(ANIM_IDLE)

func play_walk() -> void:
	if is_dead() or is_attacking():
		return
	_play(ANIM_WALK)

func play_run() -> void:
	if is_dead() or is_attacking():
		return
	_play(ANIM_RUN)

func play_dance() -> void:
	if is_dead():
		return
	_play(ANIM_DANCE)

func play_attack() -> void:
	if is_dead():
		return
	_play(ANIM_ATTACK)

func play_dead() -> void:
	_play(ANIM_DEAD)

func _play(anim: String) -> void:
	if animation_player and animation_player.has_animation(anim):
		if animation_player.current_animation != anim or not animation_player.is_playing():
			animation_player.play(anim)

