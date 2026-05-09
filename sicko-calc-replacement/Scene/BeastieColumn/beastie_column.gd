@tool
class_name BeastieColumn
extends MarginContainer

const SPRECKO = preload("res://Autoloads/Resources/Beastie/Sprecko/sprecko.tres")
const FREE_BALL = preload("res://Autoloads/Resources/Plays/Attack/Body/free_ball.tres")
const ICON_ROW_NET = preload("uid://i3su3ma1wc5")
const ICON_ROW_BACK = preload("uid://dhs73i0hc16qu")

signal beastie_updated
signal plays_select_ui_requested
signal trait_select_ui_requested

@export var beastie : Beastie = null:
	set(value):
		beastie = value
		update_beastie()


@export var side : Global.MySide = Global.MySide.LEFT :
	set(value):
		side = value
		_update_side()

var current_attack : Attack = FREE_BALL:
	set(value):
		current_attack = value
		_update_attack()


var trait_one : Trait = SPRECKO.possible_traits[0].duplicate(true)
var trait_two : Trait = SPRECKO.possible_traits[1].duplicate(true)
var current_pos : Beastie.Position = Beastie.Position.UPPER_BACK

@onready var beastie_row: BeastieRow = %BeastieRow

@onready var trait_one_button: Button = %TraitOneButton
@onready var trait_two_button: Button = %TraitTwoButton
@onready var custom_trait_button: Button = %CustomTraitButton

@onready var trait_condition_row: HBoxContainer = %TraitConditionRow
@onready var trait_condition_button: Button = %TraitConditionButton

@onready var back_button: Button = %BackButton
@onready var net_button: Button = %NetButton

@onready var attack_row: HBoxContainer = %AttackRow
@onready var select_attack_button: Button = %SelectAttackButton
@onready var attack_plays_ui: PlaysUI = %AttackPlaysUI
@onready var mimic_button: Button = %MimicButton

@onready var attack_condition_row: HBoxContainer = %AttackConditionRow
@onready var attack_condition_button: Button = %AttackConditionButton

@onready var boost_row: BoostRow = %BoostRow


func _ready() -> void:
	var is_left : bool = side == Global.MySide.LEFT
	attack_row.visible = is_left
	attack_condition_row.visible = is_left
	boost_row.side = side

	if is_left:
		select_attack_button.pressed.connect(plays_select_ui_requested.emit)

	var trait_button_group := ButtonGroup.new()
	trait_one_button.button_group = trait_button_group
	trait_two_button.button_group = trait_button_group
	custom_trait_button.button_group = trait_button_group
	trait_one_button.pressed.connect(_on_trait_button_pressed.bind(1))
	trait_two_button.pressed.connect(_on_trait_button_pressed.bind(2))
	custom_trait_button.pressed.connect(trait_select_ui_requested.emit)
	custom_trait_button.toggled.connect(func(toggled_on : bool):
		if not toggled_on:
			custom_trait_button.text = "Custom"
	)

	trait_condition_button.toggled.connect(_on_trait_condtion_toggled)

	var pos_button_group := ButtonGroup.new()
	back_button.button_group = pos_button_group
	net_button.button_group = pos_button_group
	back_button.pressed.connect(_on_pos_button_pressed.bind(Beastie.Position.UPPER_BACK))
	net_button.pressed.connect(_on_pos_button_pressed.bind(Beastie.Position.UPPER_FRONT))

	attack_condition_button.toggled.connect(_on_attack_condtion_toggled)

	boost_row.boost_updated.connect(_on_boost_updated)
	boost_row.invest_updated.connect(_on_invest_updated)

	_update_attack()

	beastie = SPRECKO.duplicate(true)


func update_beastie() -> void:
	if not is_node_ready():
		await ready
	if not beastie:
		return

	beastie_row.beastie = beastie
	beastie.my_field_position = current_pos

	_update_trait_button()
	_update_trait_condition_button()

	trait_one_button.button_pressed = true
	_on_trait_button_pressed(1) # beastie_updated.emit() in here


func _update_side() -> void:
	if not is_node_ready():
		await ready
	beastie_row.side = side


func _update_attack() -> void:
	if not is_node_ready():
		await ready

	boost_row.attack = current_attack

	if not side == Global.MySide.LEFT:
		attack_row.hide()
		return

	if not current_attack:
		select_attack_button.flat = false
		attack_plays_ui.hide()
		attack_condition_row.hide()

	else:
		beastie.my_plays[0] = current_attack

		select_attack_button.flat = true
		attack_plays_ui.my_play = current_attack
		attack_plays_ui.show()

		attack_condition_row.visible = current_attack.need_to_be_manually_activated
		attack_condition_button.button_pressed = false
		attack_condition_button.text = current_attack.condition_name


func _on_attack_condtion_toggled(toggled_on) -> void:
	if not current_attack:
		return
	current_attack.manually_activated = toggled_on
	beastie_updated.emit()


func _update_trait_button() -> void:
	trait_one = beastie.possible_traits[0].duplicate(true)
	trait_one_button.text = trait_one.name
	if beastie.possible_traits.size() > 1:
		trait_two_button.show()
		trait_two = beastie.possible_traits[1].duplicate(true)
		trait_two_button.text = trait_two.name
	else:
		trait_two_button.hide()
		trait_two = null
		trait_two_button.text = "ERROR!!!" # Shouldn't see this


func _update_trait_condition_button() -> void:
	trait_condition_button.button_pressed = false
	trait_condition_row.visible = false

	var the_trait : Trait = beastie.my_trait
	var is_left : bool = side == Global.MySide.LEFT
	if ((the_trait.damage_dealt_mult != 1.0 or the_trait.is_starter_trait) and is_left) or \
		(the_trait.def_mult != 1.0 and not is_left):
		trait_condition_row.visible = beastie.my_trait.need_to_be_manually_activated
		trait_condition_button.text = beastie.my_trait.condition_name


func update_custom_trait_button() -> void:
	if beastie.my_trait == null:
		return

	var trait_name : String = beastie.my_trait.name
	custom_trait_button.text = trait_name
	custom_trait_button.button_pressed = true
	_update_trait_condition_button()
	if trait_name.to_lower() == "shy":
		back_button.icon = ICON_ROW_NET
		net_button.icon = ICON_ROW_BACK
	else:
		back_button.icon = ICON_ROW_BACK
		net_button.icon = ICON_ROW_NET
	beastie_updated.emit()


func _on_trait_button_pressed(trait_number : int) -> void:
	if not beastie:
		return # Shouldn't happen
	trait_one.manually_activated = false
	if trait_two:
		trait_two.manually_activated = false
	var new_trait : Trait = trait_one if trait_number == 1 else trait_two
	if new_trait and new_trait == beastie.my_trait:
		return
	beastie.my_trait = new_trait
	_update_trait_condition_button()
	if new_trait.name.to_lower() == "shy":
		back_button.icon = ICON_ROW_NET
		net_button.icon = ICON_ROW_BACK
	else:
		back_button.icon = ICON_ROW_BACK
		net_button.icon = ICON_ROW_NET

	beastie_updated.emit()


func _on_trait_condtion_toggled(toggled_on) -> void:
	if not beastie:
		return
	beastie.my_trait.manually_activated = toggled_on
	beastie_updated.emit()


func _on_pos_button_pressed(pos : Beastie.Position) -> void:
	if not beastie:
		return
	current_pos = pos
	beastie.my_field_position = pos
	beastie_updated.emit()


func _on_boost_updated(stat : Beastie.Stats, amount : int) -> void:
	if not beastie:
		return
	beastie.current_boosts[stat] = amount
	beastie_updated.emit()


func _on_invest_updated(stat : Beastie.Stats, amount : int) -> void:
	if not beastie:
		return
	beastie.invests[stat] = amount
	beastie_updated.emit()
