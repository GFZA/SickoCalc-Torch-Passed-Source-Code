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
signal rally_requested(toggled_on : bool)
signal stamina_change_requested(value : int)

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
@onready var rally_button: Button = %RallyButton

@onready var attack_condition_row: HBoxContainer = %AttackConditionRow
@onready var attack_condition_margin: MarginContainer = %AttackConditionMargin
@onready var attack_condition_button: Button = %AttackConditionButton
@onready var stamina_container: StaminaContainer = %StaminaContainer
@onready var volley_amount_container: HBoxContainer = %VolleyAmountContainer
@onready var volley_number_ui: NumberUI = %VolleyNumberUI

@onready var boost_row: BoostRow = %BoostRow

@onready var left_feeling_container: HBoxContainer = %LeftFeelingContainer
@onready var jazzed_button: Button = %JazzedButton
@onready var left_weepy_button: Button = %LeftWeepyButton
@onready var blocked_number_ui: NumberUIAlt = %BlockedNumberUI

@onready var right_feeling_container: HBoxContainer = %RightFeelingContainer
@onready var tough_button: Button = %ToughButton
@onready var right_weepy_button: Button = %RightWeepyButton
@onready var tender_button: Button = %TenderButton


func _ready() -> void:
	var is_left : bool = side == Global.MySide.LEFT
	attack_row.visible = is_left
	attack_condition_row.visible = is_left
	boost_row.side = side

	beastie_updated.connect(beastie_row.update_beastie)

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
	rally_button.toggled.connect(rally_requested.emit)
	mimic_button.toggled.connect(_on_mimic_button_toggled)

	stamina_container.value_updated.connect(_on_stamina_changed)
	volley_number_ui.value_updated.connect(_on_volley_amount_changed)

	boost_row.boost_updated.connect(_on_boost_updated)
	boost_row.invest_updated.connect(_on_invest_updated)

	if is_left:
		left_feeling_container.show()
		right_feeling_container.hide()
		var left_field_button_group := ButtonGroup.new()
		left_field_button_group.allow_unpress = true
		jazzed_button.button_group = left_field_button_group
		left_weepy_button.button_group = left_field_button_group
		jazzed_button.toggled.connect(_on_feeling_button_toggled.bind(Beastie.Feelings.JAZZED))
		left_weepy_button.toggled.connect(_on_feeling_button_toggled.bind(Beastie.Feelings.WEEPY))
		blocked_number_ui.value_updated.connect(_on_blocked_updated)
	else:
		left_feeling_container.hide()
		right_feeling_container.show()
		var right_field_button_group := ButtonGroup.new()
		right_field_button_group.allow_unpress = true
		tough_button.button_group = right_field_button_group
		tender_button.button_group = right_field_button_group
		tough_button.toggled.connect(_on_feeling_button_toggled.bind(Beastie.Feelings.TOUGH))
		right_weepy_button.toggled.connect(_on_feeling_button_toggled.bind(Beastie.Feelings.WEEPY))
		tender_button.toggled.connect(_on_feeling_button_toggled.bind(Beastie.Feelings.TENDER))

	boost_row.reset_requested.connect(reset)

	beastie = SPRECKO.duplicate(true)
	_update_attack()


func update_beastie() -> void:
	if not is_node_ready():
		await ready
	if not beastie:
		return

	beastie_row.beastie = beastie
	beastie.my_field_position = current_pos

	mimic_button.visible = beastie.specie_name.to_lower() in ["squimage", "diabloceras"]

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

		var attack_name : String = current_attack.name.to_lower()
		var is_vigor_beam : bool = attack_name == "vigor beam"
		var is_soulcrusher : bool = attack_name == "soulcrusher"
		var is_zigzag : bool = attack_name == "zigzag"
		attack_condition_row.visible = current_attack.need_to_be_manually_activated or \
								is_vigor_beam or is_soulcrusher or is_zigzag

		attack_condition_margin.visible = current_attack.need_to_be_manually_activated
		attack_condition_button.visible = current_attack.need_to_be_manually_activated
		attack_condition_button.button_pressed = false
		attack_condition_button.text = current_attack.condition_name

		stamina_container.visible = is_vigor_beam or is_soulcrusher
		volley_amount_container.visible = is_zigzag

		rally_button.visible = current_attack.type in [Plays.Type.ATTACK_SPIRIT, Plays.Type.ATTACK_MIND] \
								or beastie.my_trait.name.to_lower() == "extrovert"


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

	# A bit unrelated but it needed be update here too, so...
	rally_button.visible = current_attack.type in [Plays.Type.ATTACK_SPIRIT, Plays.Type.ATTACK_MIND] \
					or beastie.my_trait.name.to_lower() == "extrovert"


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

	if trait_name.to_lower() == "musclebrain":
		boost_row.reset_all_ui(true)

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
	var old_trait : Trait = beastie.my_trait
	beastie.my_trait = new_trait
	_update_trait_condition_button()
	if new_trait.name.to_lower() == "shy":
		back_button.icon = ICON_ROW_NET
		net_button.icon = ICON_ROW_BACK
	else:
		back_button.icon = ICON_ROW_BACK
		net_button.icon = ICON_ROW_NET
	if old_trait.name.to_lower() == "musclebrain":
		boost_row.reset_all_ui()

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


func _on_mimic_button_toggled(toggled_on : bool) -> void:
	if not beastie or not current_attack:
		return
	current_attack.is_mimicked = toggled_on
	beastie_updated.emit()


func _on_stamina_changed(value : int) -> void:
	match current_attack.name.to_lower():
		"vigor beam":
			stamina_container.text = "User STAMINA"
			beastie.health = value
		"soulcrusher":
			stamina_container.text = "Target STAMINA"
			stamina_change_requested.emit(value)
	beastie_updated.emit()


func _on_volley_amount_changed(value : int) -> void:
	if current_attack.name.to_lower() != "zigzag":
		return
	current_attack.volley_amount = value
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


func _on_feeling_button_toggled(toggled_on : bool, feeling : Beastie.Feelings) -> void:
	if not beastie:
		return
	if toggled_on:
		beastie.current_feelings.get_or_add(feeling, 1)
	elif beastie.current_feelings.has(feeling):
		beastie.current_feelings.erase(feeling)
	beastie_updated.emit()


func _on_blocked_updated(amount : int) -> void:
	if not beastie:
		return
	beastie.current_feelings[Beastie.Feelings.BLOCKED] = amount
	if amount == 0:
		if beastie.current_feelings.has(Beastie.Feelings.BLOCKED):
			beastie.current_feelings.erase(Beastie.Feelings.BLOCKED)
	beastie_updated.emit()


func reset() -> void:
	if beastie:
		beastie.health = 100

	jazzed_button.button_pressed = false
	left_weepy_button.button_pressed = false
	blocked_number_ui.reset()
	tough_button.button_pressed = false
	right_weepy_button.button_pressed = false
	tender_button.button_pressed = false

	back_button.button_pressed = true
	_on_pos_button_pressed(Beastie.Position.UPPER_BACK)

	rally_button.button_pressed = false
	mimic_button.button_pressed = false

	stamina_container.reset()
	stamina_change_requested.emit(100)
	volley_number_ui.reset()

	trait_one_button.button_pressed = true
	trait_condition_button.button_pressed = false
	_on_trait_button_pressed(1)
