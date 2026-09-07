class_name WavePanel
extends Control

## Panel central que muestra el número de oleada ("WAVE N").

@onready var label: Label = $Root/Margin/Label

func set_wave(n: int) -> void:
	if label:
		label.text = "WAVE %d" % n
