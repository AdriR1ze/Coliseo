class_name HUD
extends Control

## Orquestador del HUD. Encaja los componentes (bars, panel de oleada, slots,
## botones) y actualiza los datos mediante señales. La estructura visual vive en
## hud.tscn; este script solo conecta señales y actualiza valores.

@onready var health_bar: HealthBar = $HealthBar
@onready var power_bar: PowerBar = $PowerBar
@onready var gold_bar: GoldBar = $GoldBar
@onready var wave_panel: WavePanel = $WavePanel
@onready var defeat_panel: DefeatPanel = $DefeatPanel

var player: Player = null

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func setup(jugador: Player) -> void:
	player = jugador
	if jugador == null:
		return
	health_bar.setup(jugador)
	power_bar.setup(jugador)
	gold_bar.setup(jugador)
	if jugador.health and not jugador.health.died.is_connected(_on_player_died):
		jugador.health.died.connect(_on_player_died)

## Refresca los datos tras aplicar un item.
func refrescar(jugador: Player) -> void:
	power_bar.setup(jugador)

func set_wave(n: int) -> void:
	if wave_panel:
		wave_panel.set_wave(n)

func _on_player_died() -> void:
	if defeat_panel:
		defeat_panel.mostrar()
