extends SceneTree

func _initialize() -> void:
	var packed := load("res://models/character_model.glb") as PackedScene
	var node := packed.instantiate()
	var meshes := node.find_children("*", "MeshInstance3D", true, false)
	print("mesh count: ", meshes.size())
	for m in meshes:
		print("MESH: ", m.name, " parent=", m.get_parent().name, " mesh=", str(m.mesh))
	var skels := node.find_children("*", "Skeleton3D", true, false)
	print("skeleton count: ", skels.size())
	for s in skels:
		print("SKEL: ", s.name, " parent=", s.get_parent().name, " skin_count=", str((s as Skeleton3D).get_bone_count()))
	var anims := node.find_children("*", "AnimationPlayer", true, false)
	print("animplayer count: ", anims.size())
	print("ROOT children:")
	for c in node.get_children():
		print("  ", c.name, " [", c.get_class(), "]")
	quit()
