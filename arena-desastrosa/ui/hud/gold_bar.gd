class_name GoldBar
extends Control

## Contador de monedas del jugador (icono + total). No es una barra,
## porque no hay un máximo que rellenar.

@onready var value_label: Label = $Root/Pill/PillInner/Value

func setup(_jugador: Player) -> void:
	set_gold(0)

func set_gold(valor: int, _max_valor: int = 0) -> void:
	if value_label:
		value_label.text = str(valor)
