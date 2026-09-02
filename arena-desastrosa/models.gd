class_name Models
extends RefCounted

const CHARACTER_SCENE := preload("res://models/character_model.tscn")

const ANIM_IDLE := CharacterModel.ANIM_IDLE
const ANIM_WALKING_NAME := CharacterModel.ANIM_WALK
const ANIM_RUNNING_NAME := CharacterModel.ANIM_RUN
const ANIM_BOOM_DANCE_NAME := CharacterModel.ANIM_DANCE
const ANIM_ATTACK_NAME := CharacterModel.ANIM_ATTACK
const ANIM_DEAD_NAME := CharacterModel.ANIM_DEAD

static func adjuntar_personaje(padre: Node3D, alto: float = 1.8) -> CharacterModel:
	var personaje := CHARACTER_SCENE.instantiate() as CharacterModel
	padre.add_child(personaje)
	personaje.scale = Vector3.ONE * (alto / 1.8)
	return personaje

static func obtener_anim_player(personaje: Node) -> AnimationPlayer:
	if personaje is CharacterModel:
		return personaje.animation_player
	return personaje.get_node_or_null("AnimationPlayer") as AnimationPlayer
