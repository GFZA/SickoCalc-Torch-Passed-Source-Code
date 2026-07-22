@tool
class_name BoostRow
extends MarginContainer

const EMPTY_STAT : Dictionary[Beastie.Stats, int] = {
		Beastie.Stats.B_POW : 0,
		Beastie.Stats.S_POW : 0,
		Beastie.Stats.M_POW : 0,
		Beastie.Stats.B_DEF : 0,
		Beastie.Stats.S_DEF : 0,
		Beastie.Stats.M_DEF : 0,
	}

signal boost_updated(stat_dict : Dictionary[Beastie.Stats, int])
signal invest_updated(stat_dict : Dictionary[Beastie.Stats, int])
signal reset_requested

@export var attack : Attack = null :
	set(value):
		var same_type : bool = false
		# ‘same_type’ is a bad naming on my end, it’s there to check if I want to reset all the boosts and invests
		# on the UIs, which I don’t want to do so when the new attack and the previous one have the same type,
		# i.e. you’re calcing for +2 +30bpow kasaleet thump then switch to demolish, it will still retain the +2 boosts
		# and +30 invest. I later make the ‘same_type’ always true when Global.is_musclebrained so it won’t reset
		# when i.e. you’re calcing for +2 musclebrain careful shot then switch to any other attacks even with
		# different types and it will retain the +2 since it’s always body.
		if attack:
			if side == Global.MySide.RIGHT:
				same_type = (value.type == attack.type or Global.is_musclebrained)\
							and not value.name.to_lower() in ["energized", "toppler", "pierce", "contest", "snipe"] # Force reset
			else:
				same_type = (value.type == attack.type or Global.is_musclebrained)
		attack = value
		if not is_node_ready():
			await ready
		_update_attack_ui()
		reset_all_ui(true, same_type)
		match attack.name.to_lower():
			"energized":
				show_energized()
			"toppler", "pierce":
				show_toppler()
			"contest", "snipe":
				show_contest()
			_:
				show_normal()

var side : Global.MySide = Global.MySide.LEFT :
	set(value):
		side = value
		_update_side()

var current_stat : Beastie.Stats = Beastie.Stats.B_POW

var boost_dict : Dictionary[Beastie.Stats, int] = {} : # Boosts doesn't need all 6 stats to exist to work properly
	set(value):
		boost_dict = value
		boost_updated.emit(boost_dict)

var invest_dict : Dictionary[Beastie.Stats, int] = EMPTY_STAT.duplicate() : # Invests NEED all 6 stats to exist to work properly
	set(value):
		invest_dict = value
		invest_updated.emit(invest_dict)

@onready var main_container: HBoxContainer = %MainContainer

@onready var boosts_column: HBoxContainer = %BoostsColumn
@onready var single_boost_display: VBoxContainer = %SingleBoostDisplay
@onready var boosts_text_label: Label = %BoostsTextLabel
@onready var boost_number_ui: NumberUIAlt = %BoostNumberUI

@onready var all_boost_uis: VBoxContainer = %AllBoostUIs
@onready var bpow_number_ui: NumberUI = %BPOWNumberUI
@onready var bdef_number_ui: NumberUI = %BDEFNumberUI
@onready var spow_number_ui: NumberUI = %SPOWNumberUI
@onready var sdef_number_ui: NumberUI = %SDEFNumberUI
@onready var mpow_number_ui: NumberUI = %MPOWNumberUI
@onready var mdef_number_ui: NumberUI = %MDEFNumberUI

@onready var reset_button: Button = %ResetButton

@onready var invest_column: HBoxContainer = %InvestColumn
@onready var single_invest_display: VBoxContainer = %SingleInvestDisplay
@onready var invest_text_label: Label = %InvestTextLabel
@onready var invest_number_ui: NumberUIAlt = %InvestNumberUI

@onready var all_invest_uis: VBoxContainer = %AllInvestUIs
@onready var bdef_invest_number_ui: NumberUI = %BDEFInvestNumberUI
@onready var sdef_invest_number_ui: NumberUI = %SDEFInvestNumberUI
@onready var mdef_invest_number_ui: NumberUI = %MDEFInvestNumberUI


func _ready() -> void:
	Global.is_musclebrained_updated.connect(_update_attack_ui.unbind(1))

	boost_number_ui.value_updated.connect(on_boost_ui_updated.unbind(1))
	bpow_number_ui.value_updated.connect(on_boost_ui_updated.unbind(1))
	spow_number_ui.value_updated.connect(on_boost_ui_updated.unbind(1))
	mpow_number_ui.value_updated.connect(on_boost_ui_updated.unbind(1))
	bdef_number_ui.value_updated.connect(on_boost_ui_updated.unbind(1))
	sdef_number_ui.value_updated.connect(on_boost_ui_updated.unbind(1))
	mdef_number_ui.value_updated.connect(on_boost_ui_updated.unbind(1))

	reset_button.pressed.connect(reset_all_ui)

	invest_number_ui.value_updated.connect(on_invest_ui_updated.unbind(1))
	bdef_invest_number_ui.value_updated.connect(on_invest_ui_updated.unbind(1))
	sdef_invest_number_ui.value_updated.connect(on_invest_ui_updated.unbind(1))
	mdef_invest_number_ui.value_updated.connect(on_invest_ui_updated.unbind(1))


func _update_attack_ui() -> void:
	if not attack:
		_update_ui_bg(Color(1.0, 1.0, 1.0, 0.0))
	var is_left : bool = side == Global.MySide.LEFT
	if Global.is_musclebrained:
		current_stat = Beastie.Stats.B_POW if is_left else Beastie.Stats.B_DEF
		_update_ui_bg(Global.get_main_color(Global.ColorType.BODY))
	else:
		match attack.type:
			Plays.Type.ATTACK_BODY:
				current_stat = Beastie.Stats.B_POW if is_left else Beastie.Stats.B_DEF
				_update_ui_bg(Global.get_main_color(Global.ColorType.BODY))
			Plays.Type.ATTACK_SPIRIT:
				current_stat = Beastie.Stats.S_POW if is_left else Beastie.Stats.S_DEF
				_update_ui_bg(Global.get_main_color(Global.ColorType.SPIRIT))
			Plays.Type.ATTACK_MIND:
				current_stat = Beastie.Stats.M_POW if is_left else Beastie.Stats.M_DEF
				_update_ui_bg(Global.get_main_color(Global.ColorType.MIND))


func on_boost_ui_updated() -> void:
	var new_boost_dict : Dictionary[Beastie.Stats, int] = {}
	if all_boost_uis.visible:
		new_boost_dict[Beastie.Stats.B_POW] = bpow_number_ui.num
		new_boost_dict[Beastie.Stats.S_POW] = spow_number_ui.num
		new_boost_dict[Beastie.Stats.M_POW] = mpow_number_ui.num
		new_boost_dict[Beastie.Stats.B_DEF] = bdef_number_ui.num
		new_boost_dict[Beastie.Stats.S_DEF] = sdef_number_ui.num
		new_boost_dict[Beastie.Stats.M_DEF] = mdef_number_ui.num
	else:
		new_boost_dict[current_stat] = boost_number_ui.num
	boost_dict = new_boost_dict


func on_invest_ui_updated() -> void:
	var new_invest_dict : Dictionary[Beastie.Stats, int] = EMPTY_STAT.duplicate()
	if all_invest_uis.visible:
		new_invest_dict[Beastie.Stats.B_DEF] = bdef_invest_number_ui.num
		new_invest_dict[Beastie.Stats.S_DEF] = sdef_invest_number_ui.num
		new_invest_dict[Beastie.Stats.M_DEF] = mdef_invest_number_ui.num
	else:
		new_invest_dict[current_stat] = invest_number_ui.num
	invest_dict = new_invest_dict


func _update_ui_bg(color : Color) -> void:
	boost_number_ui.color = color
	invest_number_ui.color = color


func _update_side() -> void:
	if not is_node_ready():
		await ready
	var is_left : bool = side == Global.MySide.LEFT
	var prefix : String = "POW" if is_left else "DEF"
	boosts_text_label.text = prefix + " Boosts"
	invest_text_label.text = prefix + " Invests"

	var boost_index : int = main_container.get_child_count() if is_left else 0
	var invest_index : int = 0 if is_left else main_container.get_child_count()
	main_container.move_child(boosts_column, boost_index)
	main_container.move_child(invest_column, invest_index)


func show_normal() -> void:
	all_boost_uis.hide()
	all_invest_uis.hide()
	single_boost_display.show()
	single_invest_display.show()


func show_energized() -> void:
	all_boost_uis.visible = side == Global.MySide.LEFT
	all_invest_uis.hide()
	single_boost_display.visible = side == Global.MySide.RIGHT
	single_invest_display.show()


func show_toppler() -> void:
	all_boost_uis.visible = side == Global.MySide.RIGHT
	all_invest_uis.hide()
	single_boost_display.visible = side == Global.MySide.LEFT
	single_invest_display.show()


func show_contest() -> void:
	all_boost_uis.visible = side == Global.MySide.RIGHT
	all_invest_uis.visible = side == Global.MySide.RIGHT
	single_boost_display.visible = side == Global.MySide.LEFT
	single_invest_display.visible = side == Global.MySide.LEFT


func show_single_boost_ui() -> void:
	all_boost_uis.hide()
	single_boost_display.show()


func reset_all_ui(no_emit : bool = false, same_type : bool = false) -> void:
	if not all_boost_uis.visible:
		if not same_type:
			boost_number_ui.reset()
			boost_dict = {}
	else:
		bpow_number_ui.reset()
		bdef_number_ui.reset()
		spow_number_ui.reset()
		sdef_number_ui.reset()
		mpow_number_ui.reset()
		mdef_number_ui.reset()

	if not all_invest_uis.visible:
		if not same_type:
			invest_number_ui.reset()
			invest_dict = EMPTY_STAT.duplicate()
	else:
		bdef_invest_number_ui.reset()
		sdef_invest_number_ui.reset()
		mdef_invest_number_ui.reset()

	if no_emit:
		return

	reset_requested.emit()
