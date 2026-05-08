@tool
class_name BeastieColumn
extends MarginContainer

const SPRECKO = preload("uid://p68xjhmdw3hk")
const FREE_BALL : Plays = preload("uid://1gwxenj63w75")

signal beastie_updated
signal plays_select_ui_requested

@export var beastie : Beastie = null:
	set(value):
		beastie = value
		_update_beastie()


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

@onready var back_button: Button = %BackButton
@onready var net_button: Button = %NetButton

@onready var attack_row: HBoxContainer = %AttackRow
@onready var select_attack_button: Button = %SelectAttackButton
@onready var attack_plays_ui: PlaysUI = %AttackPlaysUI
@onready var mimic_button: Button = %MimicButton

@onready var boost_row: BoostRow = %BoostRow


func _ready() -> void:
	var is_left : bool = side == Global.MySide.LEFT
	attack_row.visible = is_left
	boost_row.side = side

	if is_left:
		select_attack_button.pressed.connect(plays_select_ui_requested.emit)

	var trait_button_group := ButtonGroup.new()
	trait_one_button.button_group = trait_button_group
	trait_two_button.button_group = trait_button_group
	trait_one_button.pressed.connect(_on_trait_button_pressed.bind(1))
	trait_two_button.pressed.connect(_on_trait_button_pressed.bind(2))

	var pos_button_group := ButtonGroup.new()
	back_button.button_group = pos_button_group
	net_button.button_group = pos_button_group
	back_button.pressed.connect(_on_pos_button_pressed.bind(Beastie.Position.UPPER_BACK))
	net_button.pressed.connect(_on_pos_button_pressed.bind(Beastie.Position.UPPER_FRONT))

	boost_row.boost_updated.connect(_on_boost_updated)
	boost_row.invest_updated.connect(_on_invest_updated)

	_update_attack()

	beastie = SPRECKO.duplicate(true)


func _update_beastie() -> void:
	if not is_node_ready():
		await ready
	if not beastie:
		return

	beastie_row.beastie = beastie
	beastie.my_field_position = current_pos

	_update_trait_button()

	beastie_updated.emit()


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
	else:
		select_attack_button.flat = true
		attack_plays_ui.my_play = current_attack
		attack_plays_ui.show()


func _on_trait_button_pressed(trait_number : int) -> void:
	if not beastie:
		return # Shouldn't happen
	beastie.my_trait = trait_one if trait_number == 1 else trait_two
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
		if trait_two_button.button_pressed:
			trait_one_button.button_pressed = true


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
