class_name MainMenu
extends Control

## Menú principal. Los botones PLAY / CLASSES / EXIT ya están conectados;
## los demás (UPGRADES, CODEX, SETTINGS, ACHIEVEMENTS, CREDITS) quedan
## como estancias listas para conectarse.

func _ready() -> void:
	%Play.pressed.connect(_on_play)
	%Classes.pressed.connect(_on_classes)
	%Exit.pressed.connect(_on_exit)

func _on_play() -> void:
	get_tree().change_scene_to_file("res://ui/class_select.tscn")

func _on_classes() -> void:
	get_tree().change_scene_to_file("res://ui/class_select.tscn")

func _on_exit() -> void:
	get_tree().quit()
