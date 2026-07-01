@tool
class_name BoostRow
extends MarginContainer

signal boost_updated(stat : Beastie.Stats, amount : int)
signal invest_updated(stat : Beastie.Stats, amount : int)
signal reset_requested

@export var attack : Attack = null :
	set(value):
		var same_type : bool = false
		if attack:
			same_type = value.type == attack.type
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

	boost_number_ui.value_updated.connect(_on_boost_updated)

	bpow_number_ui.value_updated.connect(_on_all_ui_boost_updated.bind(Beastie.Stats.B_POW))
	spow_number_ui.value_updated.connect(_on_all_ui_boost_updated.bind(Beastie.Stats.S_POW))
	mpow_number_ui.value_updated.connect(_on_all_ui_boost_updated.bind(Beastie.Stats.M_POW))
	bdef_number_ui.value_updated.connect(_on_all_ui_boost_updated.bind(Beastie.Stats.B_DEF))
	sdef_number_ui.value_updated.connect(_on_all_ui_boost_updated.bind(Beastie.Stats.S_DEF))
	mdef_number_ui.value_updated.connect(_on_all_ui_boost_updated.bind(Beastie.Stats.M_DEF))

	reset_button.pressed.connect(reset_all_ui)

	invest_number_ui.value_updated.connect(_on_invest_updated)

	bdef_invest_number_ui.value_updated.connect(_on_all_ui_invest_updated.bind(Beastie.Stats.B_DEF))
	sdef_invest_number_ui.value_updated.connect(_on_all_ui_invest_updated.bind(Beastie.Stats.S_DEF))
	mdef_invest_number_ui.value_updated.connect(_on_all_ui_invest_updated.bind(Beastie.Stats.M_DEF))


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


func _on_boost_updated(amount : int) -> void:
	boost_updated.emit(current_stat, amount)


func _on_all_ui_boost_updated(amount : int, stat : Beastie.Stats) -> void:
	boost_updated.emit(stat, amount)


func _on_invest_updated(amount : int) -> void:
	invest_updated.emit(current_stat, amount)


func _on_all_ui_invest_updated(amount : int, stat : Beastie.Stats) -> void:
	invest_updated.emit(stat, amount)


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
	else:
		bdef_invest_number_ui.reset()
		sdef_invest_number_ui.reset()
		mdef_invest_number_ui.reset()

	if no_emit:
		return

	reset_requested.emit()
