class_name DefeatPanel
extends Control

## Pantalla de derrota centrada.

func _ready() -> void:
	var reintentar := get_node_or_null("Center/Panel/Margin/VBox/Reintentar")
	var cambiar := get_node_or_null("Center/Panel/Margin/VBox/Cambiar")
	if reintentar:
		(reintentar as Button).pressed.connect(_on_reintentar_pressed)
	if cambiar:
		(cambiar as Button).pressed.connect(_on_cambiar_pressed)

func mostrar() -> void:
	visible = true

func _on_reintentar_pressed() -> void:
	GameManager.ir_a_combate()
	get_tree().reload_current_scene()

func _on_cambiar_pressed() -> void:
	GameManager.ir_a_seleccion_clase()
	get_tree().change_scene_to_file("res://ui/class_select.tscn")
