@tool
class_name PlaysSelectUI
extends Control

signal plays_selected(plays : Plays, slot_index : int, side : Global.MySide, team_pos : TeamController.TeamPosition)

const PLAY_BUTTON : PackedScene = preload("uid://dflcrna6d1235")
const FREE_BALL : Plays = preload("uid://1gwxenj63w75")

@export var beastie : Beastie = null :
	set(value):
		beastie = value
		_update_beastie_plays_data()
		update_grid()

var side : Global.MySide = Global.MySide.LEFT
var team_pos : TeamController.TeamPosition = TeamController.TeamPosition.FIELD_1
var slot_index : int = 0

var all_body_attacks : Array[Plays] = []
var all_spirit_attacks : Array[Plays] = []
var all_mind_attacks : Array[Plays] = []
var all_volley_plays : Array[Plays] = []
var all_support_plays : Array[Plays] = []
var all_defense_plays : Array[Plays] = []
var all_plays : Array[Plays] = []

var beastie_body_attacks : Array[Plays] = []
var beastie_spirit_attacks : Array[Plays] = []
var beastie_mind_attacks : Array[Plays] = []
var beastie_volley_plays : Array[Plays] = []
var beastie_support_plays : Array[Plays] = []
var beastie_defense_plays : Array[Plays] = []
var beastie_plays : Array[Plays] = []

var current_filter : Plays.Type = Plays.Type.NONE :
	set(value):
		current_filter = value
		update_grid()

var allows_illegal_plays : bool = false :
	set(value):
		allows_illegal_plays = value
		update_grid()

var current_search_string : String = "" :
	set(value):
		current_search_string = value
		update_grid()

@onready var plays_button_container: GridContainer = %PlaysButtonContainer
@onready var search_bar: LineEdit = %SearchBar
@onready var none_plays_filter_button: Button = %NonePlaysFilterButton
@onready var body_plays_filter_button: Button = %BodyPlaysFilterButton
@onready var spirit_plays_filter_button: Button = %SpiritPlaysFilterButton
@onready var mind_plays_filter_button: Button = %MindPlaysFilterButton
@onready var volley_plays_filter_button: Button = %VolleyPlaysFilterButton
@onready var support_plays_filter_button: Button = %SupportPlaysFilterButton
@onready var defense_plays_filter_button: Button = %DefensePlaysFilterButton
@onready var allow_illegal_plays_check_box: CheckBox = %AllowIllegalPlaysCheckBox


func _ready() -> void:
	search_bar.text_changed.connect(func(new_text : String): current_search_string = new_text)
	none_plays_filter_button.pressed.connect(func(): current_filter = Plays.Type.NONE)
	body_plays_filter_button.pressed.connect(func(): current_filter = Plays.Type.ATTACK_BODY)
	spirit_plays_filter_button.pressed.connect(func(): current_filter = Plays.Type.ATTACK_SPIRIT)
	mind_plays_filter_button.pressed.connect(func(): current_filter = Plays.Type.ATTACK_MIND)
	volley_plays_filter_button.pressed.connect(func(): current_filter = Plays.Type.VOLLEY)
	support_plays_filter_button.pressed.connect(func(): current_filter = Plays.Type.SUPPORT)
	defense_plays_filter_button.pressed.connect(func(): current_filter = Plays.Type.DEFENSE)

	allow_illegal_plays_check_box.toggled.connect(func(toggled_on : bool): allows_illegal_plays = toggled_on)
	_assign_all_data_arrays()
	update_grid()


func _assign_all_data_arrays() -> void:
	all_body_attacks = Global.all_body_attacks.duplicate()
	all_spirit_attacks = Global.all_spirit_attacks.duplicate()
	all_mind_attacks = Global.all_mind_attacks.duplicate()
	all_volley_plays = Global.all_volley_plays.duplicate()
	all_support_plays = Global.all_support_plays.duplicate()
	all_defense_plays = Global.all_defense_plays.duplicate()
	all_plays = Global.all_plays


func _update_beastie_plays_data() -> void:
	if not beastie or not visible:
		beastie_body_attacks.clear()
		beastie_spirit_attacks.clear()
		beastie_mind_attacks.clear()
		beastie_volley_plays.clear()
		beastie_support_plays.clear()
		beastie_defense_plays.clear()
		beastie_plays.clear()
		return

	var sort_by_name : Callable = (func(a : Plays, b : Plays):
		var a_name : String = a.name
		var b_name : String = b.name
		return a_name < b_name
	)

	var pre_sort_beastie_plays = beastie.possible_plays.duplicate()

	# Body Attacks
	beastie_body_attacks = pre_sort_beastie_plays.filter(func(plays : Plays):
		return plays.type == Plays.Type.ATTACK_BODY if plays else false
	)
	beastie_body_attacks.sort_custom(sort_by_name)
	beastie_body_attacks.push_front(FREE_BALL) # Make Free Ball always the first option

	# Spirit Attacks
	beastie_spirit_attacks = pre_sort_beastie_plays.filter(func(plays : Plays):
		return plays.type == Plays.Type.ATTACK_SPIRIT if plays else false
	)
	beastie_spirit_attacks.sort_custom(sort_by_name)

	# Mind Attacks
	beastie_mind_attacks = pre_sort_beastie_plays.filter(func(plays : Plays):
		return plays.type == Plays.Type.ATTACK_MIND if plays else false
	)
	beastie_mind_attacks.sort_custom(sort_by_name)

	# Volley
	beastie_volley_plays = pre_sort_beastie_plays.filter(func(plays : Plays):
		return plays.type == Plays.Type.VOLLEY if plays else false
	)
	beastie_volley_plays.sort_custom(sort_by_name)

	# Support
	beastie_support_plays = pre_sort_beastie_plays.filter(func(plays : Plays):
		return plays.type == Plays.Type.SUPPORT if plays else false
	)
	beastie_support_plays.sort_custom(sort_by_name)

	# Defense
	beastie_defense_plays = pre_sort_beastie_plays.filter(func(plays : Plays):
		return plays.type == Plays.Type.DEFENSE if plays else false
	)
	beastie_defense_plays.sort_custom(sort_by_name)

	# All Plays
	beastie_plays.append_array(beastie_body_attacks)
	beastie_plays.append_array(beastie_spirit_attacks)
	beastie_plays.append_array(beastie_mind_attacks)
	beastie_plays.append_array(beastie_volley_plays)
	beastie_plays.append_array(beastie_support_plays)
	beastie_plays.append_array(beastie_defense_plays)


func _get_filtered_array() -> Array[Plays]:
	if not allows_illegal_plays and beastie:
		match current_filter:
			Plays.Type.NONE:
				return beastie_plays
			Plays.Type.ATTACK_BODY:
				return beastie_body_attacks
			Plays.Type.ATTACK_SPIRIT:
				return beastie_spirit_attacks
			Plays.Type.ATTACK_MIND:
				return beastie_mind_attacks
			Plays.Type.VOLLEY:
				return beastie_volley_plays
			Plays.Type.SUPPORT:
				return beastie_support_plays
			Plays.Type.DEFENSE:
				return beastie_defense_plays
	else:
		match current_filter:
			Plays.Type.NONE:
				return all_plays
			Plays.Type.ATTACK_BODY:
				return all_body_attacks
			Plays.Type.ATTACK_SPIRIT:
				return all_spirit_attacks
			Plays.Type.ATTACK_MIND:
				return all_mind_attacks
			Plays.Type.VOLLEY:
				return all_volley_plays
			Plays.Type.SUPPORT:
				return all_support_plays
			Plays.Type.DEFENSE:
				return all_defense_plays
	return []


func _get_search_filtered_array(search_string : String) -> Array[Plays]:
	var array_to_filer_again : Array[Plays] = _get_filtered_array()
	if search_string == "":
		return array_to_filer_again.duplicate()

	var result : Array[Plays] = []
	for plays : Plays in array_to_filer_again:
		if plays and plays.name.to_lower().begins_with(search_string.to_lower()):
			result.append(plays)
	return result


func update_grid() -> void:
	if not is_node_ready():
		await ready

	if not visible:
		return

	for child : PlaysButton in plays_button_container.get_children():
		child.queue_free()

	var plays_array : Array[Plays] = _get_search_filtered_array(current_search_string)

	for plays : Plays in plays_array:
		var new_button : PlaysButton = PLAY_BUTTON.instantiate()
		new_button.plays = plays
		new_button.plays_selected.connect(_on_plays_button_plays_selected)
		plays_button_container.add_child(new_button)


func _on_plays_button_plays_selected(plays : Plays) -> void:
	if not beastie:
		return
	if not plays:
		beastie.my_plays[slot_index] = null
		beastie.my_plays_updated.emit(beastie.my_plays) # Have to manually emitted for some reason)
		plays_selected.emit(null, slot_index, side, team_pos)
	else:
		beastie.my_plays[slot_index] = plays.duplicate(true)
		beastie.my_plays_updated.emit(beastie.my_plays) # Have to manually emitted for some reason)
		plays_selected.emit(beastie.my_plays[slot_index], slot_index, side, team_pos)


func reset() -> void:
	beastie = null
	side = Global.MySide.LEFT
	team_pos = TeamController.TeamPosition.FIELD_1
	current_filter = Plays.Type.NONE
	current_search_string = ""
	search_bar.text = ""
