@tool
class_name BeastieSelectUI
extends Control

signal beastie_selected(beastie : Beastie, side : Global.MySide, team_pos : TeamController.TeamPosition)

const BEASTIE_BUTTON : PackedScene = preload("uid://dpfyarbgjk6l4")

@export var show_name : bool = true :
	set(value):
		show_name = value
		update_grid()

@export var show_nfe : bool = false :
	set(value):
		show_nfe = value
		update_grid()

var beasties_only_full: Array[Beastie] = []
var beasties_only_nfe : Array[Beastie] = []

var current_search_string : String = "" :
	set(value):
		current_search_string = value
		update_grid()

var side : Global.MySide = Global.MySide.LEFT
var team_pos : TeamController.TeamPosition = TeamController.TeamPosition.FIELD_1

var remove_mode : bool = false

@onready var beastie_button_container: GridContainer = %BeastieButtonContainer
@onready var search_bar: LineEdit = %SearchBar
@onready var show_name_check_box: CheckBox = %ShowNameCheckBox
@onready var only_full_morphs_label_check_box: CheckBox = %OnlyFullMorphsLabelCheckBox


func _ready() -> void:
	search_bar.text_changed.connect(func(new_text : String): current_search_string = new_text)
	show_name_check_box.toggled.connect(func(is_toggled : bool): show_name = is_toggled)
	only_full_morphs_label_check_box.toggled.connect(func(is_toggled : bool): show_nfe = not is_toggled)

	_assign_all_data_arrays()
	update_grid()


func _assign_all_data_arrays() -> void:
	var all_data : Array[Beastie] = Global.all_beasties_data.duplicate()
	all_data.sort_custom(func(b1 : Beastie, b2 : Beastie):
		return b1.beastiepedia_id < b2.beastiepedia_id
	)

	beasties_only_full = all_data.duplicate()
	beasties_only_full = all_data.filter(func(b : Beastie):
		return b.is_nfe == false
	)

	beasties_only_nfe = all_data.duplicate()
	beasties_only_nfe = all_data.filter(func(b : Beastie):
		return b.is_nfe == true
	)


func _get_filtered_array(search_string : String) -> Array[Beastie]:
	var base_array : Array[Beastie] = beasties_only_nfe if show_nfe else beasties_only_full
	if search_string == "":
		return base_array.duplicate()

	var result : Array[Beastie] = []
	for beastie : Beastie in base_array:
		if beastie and \
		(beastie.specie_name.to_lower().begins_with(search_string.to_lower()) or \
		(beastie.beastiepedia_id == search_string.to_int())):
			result.append(beastie)
	return result


func update_grid() -> void:
	if not is_node_ready():
		await ready

	if not visible:
		return

	for child : BeastieButton in beastie_button_container.get_children():
		if child.beastie_selected.is_connected(self.beastie_selected.emit):
			child.beastie_selected.disconnect(self.beastie_selected.emit)
		child.queue_free()

	beastie_button_container.columns = 4 if show_name else 11

	var beastie_array : Array[Beastie] = _get_filtered_array(current_search_string)
	beastie_array.push_front(null) # Add None Button here

	for beastie : Beastie in beastie_array:
		var new_button : BeastieButton = BEASTIE_BUTTON.instantiate()
		new_button.beastie = beastie
		new_button.show_name = show_name
		new_button.beastie_selected.connect(_on_beastie_button_beastie_selected)
		beastie_button_container.add_child(new_button)


func _on_beastie_button_beastie_selected(beastie : Beastie) -> void:
	if not beastie:
		beastie_selected.emit(null, side, team_pos)
	else:
		beastie_selected.emit(beastie.duplicate(true), side, team_pos)


func reset() -> void:
	side = Global.MySide.LEFT
	team_pos = TeamController.TeamPosition.FIELD_1
	current_search_string = ""
	search_bar.text = ""
