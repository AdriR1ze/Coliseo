class_name ComandoExplosionFuego
extends RefCounted

const ATAQUE_FUEGO_SCENE := preload("res://efectos/ataque_fuego_circular.tscn")

func execute(usuario: Node3D) -> void:
	if usuario == null or not is_instance_valid(usuario):
		return
	
	var ataque := ATAQUE_FUEGO_SCENE.instantiate() as AtaqueFuegoCircular
	if ataque == null:
		return
	
	# Colocar el efecto en la escena principal para que no se mueva con el personaje
	var parent := usuario.get_parent()
	if parent:
		parent.add_child(ataque)
	else:
		usuario.add_child(ataque)
		
	ataque.global_position = usuario.global_position
	ataque.activar(usuario)
