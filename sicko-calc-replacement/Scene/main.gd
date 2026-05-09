class_name Main
extends Control

const FREE_BALL = preload("res://Autoloads/Resources/Plays/Attack/Body/free_ball.tres")

var current_attack : Attack = FREE_BALL :
	set(value):
		current_attack = value
		_update()

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

	left_beastie_column.plays_select_ui_requested.connect(_on_left_column_play_select_ui_requested)
	# specify if this is selecting for mimicked attack later
	select_uis.plays_selected.connect(_on_play_selected)

	left_beastie_column.trait_select_ui_requested.connect(select_uis.show_trait_select_ui.bind(Global.MySide.LEFT))
	right_beastie_column.trait_select_ui_requested.connect(select_uis.show_trait_select_ui.bind(Global.MySide.RIGHT))
	select_uis.trait_selected.connect(_on_trait_selected)

	_update()


func _on_beastie_selected(beastie : Beastie, side : Global.MySide) -> void:
	var column : BeastieColumn = left_beastie_column if side == Global.MySide.LEFT else right_beastie_column
	column.beastie = beastie

	if side != Global.MySide.LEFT:
		return

	for attack : Plays in beastie.possible_plays:
		if current_attack.name.to_lower() == attack.name.to_lower():
			return
	current_attack = FREE_BALL


func _on_left_column_play_select_ui_requested() -> void:
	select_uis.show_plays_select_ui(left_beastie_column.beastie)


func _on_play_selected(attack : Plays) -> void:
	current_attack = attack
	if not current_attack:
		current_attack = FREE_BALL


func _on_trait_selected(new_trait : Trait, side : Global.MySide) -> void:
	var column : BeastieColumn = left_beastie_column if side == Global.MySide.LEFT else right_beastie_column
	column.beastie.my_trait = new_trait
	column.update_custom_trait_button()


func _update() -> void:
	if not is_node_ready():
		await ready

	var attacker : Beastie = left_beastie_column.beastie
	var defender : Beastie = right_beastie_column.beastie

	if not attacker or not defender:
		damage_splash.amount = 0
		damage_splash.attack = null

	if attacker and defender:
		damage_splash.amount = DamageCalculator.get_damage(attacker, defender, current_attack)
		damage_splash.attack = current_attack
		if left_beastie_column.current_attack == current_attack:
			return # this prevents the most stupid accidental infinite loop I ever made, like wtf lmao
		left_beastie_column.current_attack = current_attack
		right_beastie_column.current_attack = current_attack
