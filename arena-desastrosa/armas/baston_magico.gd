class_name BastonMagico
extends BaseArma

const PROYECTIL_SCRIPT = preload("res://armas/proyectil_magico.gd")

func _init() -> void:
	nombre = "Bastón Mágico"
	dano = 28
	cooldown = 0.6
	alcance = 25.0

func atacar(portador: Node3D, direccion: Vector3) -> bool:
	if not super.atacar(portador, direccion):
		return false
	
	var dir := direccion.normalized()
	if dir.is_zero_approx():
		dir = -portador.global_transform.basis.z.normalized()
		
	var proyectil_node := Area3D.new()
	proyectil_node.set_script(PROYECTIL_SCRIPT)
	var proyectil := proyectil_node as ProyectilMagico
	proyectil.direccion = dir
	proyectil.dano = dano
	
	var root := portador.get_parent()
	if root == null:
		root = portador
		
	var spawn_pos := portador.global_position + Vector3(0, 1.2, 0) + dir * 0.8
	root.add_child(proyectil)
	proyectil.global_position = spawn_pos
	return true
