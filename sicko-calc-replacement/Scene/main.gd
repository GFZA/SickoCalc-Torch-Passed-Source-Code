class_name Main
extends Control

@onready var left_beastie_column: BeastieColumn = %LeftBeastieColumn
@onready var damage_splash: DamageSplash = %DamageSplash
@onready var right_beastie_column: BeastieColumn = %RightBeastieColumn
@onready var select_uis: SelectUIs = %SelectUIs


func _ready() -> void:
	left_beastie_column.beastie_updated.connect(_update)
	right_beastie_column.beastie_updated.connect(_update)
	left_beastie_column.beastie_row.beastie_select_ui_requested.connect(select_uis.show_beastie_select_ui.bind(Global.MySide.LEFT))
	right_beastie_column.beastie_row.beastie_select_ui_requested.connect(select_uis.show_beastie_select_ui.bind(Global.MySide.RIGHT))
	select_uis.beastie_selected.connect(_on_beastie_selected)


func _on_beastie_selected(beastie : Beastie, side : Global.MySide) -> void:
	var column : BeastieColumn = left_beastie_column if side == Global.MySide.LEFT else right_beastie_column
	column.beastie = beastie


func _update() -> void:
	var attacker : Beastie = left_beastie_column.beastie
	var defender : Beastie = right_beastie_column.beastie

	if not attacker or not defender:
		damage_splash.amount = 0
		damage_splash.attack = null

	if attacker:
		damage_splash.attack = attacker.possible_plays[0]

	if attacker and defender:
		damage_splash.amount = DamageCalculator.get_damage(attacker, defender, attacker.possible_plays[0])
