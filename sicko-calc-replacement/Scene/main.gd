class_name Main
extends Control

const FREE_BALL = preload("res://Autoloads/Resources/Plays/Attack/Body/free_ball.tres")

var current_attack : Attack = FREE_BALL :
	set(value):
		current_attack = value
		_update()

@onready var arrow_anchor: Control = %ArrowAnchor

@onready var left_beastie_column: BeastieColumn = %LeftBeastieColumn
@onready var damage_splash: DamageSplash = %DamageSplash
@onready var right_beastie_column: BeastieColumn = %RightBeastieColumn
@onready var select_uis: SelectUIs = %SelectUIs

@onready var reset_all_button: Button = %ResetButton
@onready var cheerleader_button: Button = %CheerleaderButton
@onready var friendship_button: Button = %FriendshipButton

# Fake TeamController to avoid refactor damage calc code lol
@onready var team_controller: TeamController = %TeamController


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

	left_beastie_column.rally_requested.connect(_on_rally_requested)

	cheerleader_button.toggled.connect(func(toggle_on : bool):
		team_controller.have_cheerleader = toggle_on
		_update()
	)
	friendship_button.toggled.connect(func(toggle_on : bool):
		team_controller.have_friendship = toggle_on
		_update()
	)

	reset_all_button.pressed.connect(func():
		left_beastie_column.beastie = left_beastie_column.SPRECKO.duplicate(true)
		left_beastie_column.boost_row.reset_all_ui() # will signal up to column and reset it too
		right_beastie_column.beastie = right_beastie_column.SPRECKO.duplicate(true)
		right_beastie_column.boost_row.reset_all_ui() # will signal up to column and reset it too
		cheerleader_button.button_pressed = false
		friendship_button.button_pressed = false
		team_controller.reset()
		current_attack = FREE_BALL.duplicate(true)
	)

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
		Global.is_musclebrained = attacker.my_trait.name.to_lower() == "musclebrain"

		damage_splash.amount = DamageCalculator.get_damage(attacker, defender, current_attack, team_controller, team_controller)
		damage_splash.attack = current_attack

		var index : int = int(current_attack.type)
		var color_type := index as Global.ColorType
		var new_color = Global.get_main_color(color_type)
		if Global.is_musclebrained:
			new_color = Global.get_main_color(Global.ColorType.BODY)
		for arrow : Polygon2D in arrow_anchor.get_children():
			arrow.color = new_color

		if left_beastie_column.current_attack == current_attack:
			return # this prevents the most stupid accidental infinite loop I ever made, like wtf lmao
		left_beastie_column.current_attack = current_attack
		right_beastie_column.current_attack = current_attack


func _on_rally_requested(toggled_on : bool) -> void:
	if toggled_on:
		team_controller.my_field_effects.get_or_add(FieldEffect.Type.RALLY, 1)
	elif team_controller.my_field_effects.has(FieldEffect.Type.RALLY):
		team_controller.my_field_effects.erase(FieldEffect.Type.RALLY)
	_update()
