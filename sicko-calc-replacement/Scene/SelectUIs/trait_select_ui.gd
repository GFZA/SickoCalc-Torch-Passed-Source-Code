@tool
class_name TraitSelectUI
extends Control

signal trait_selected(new_trait : Trait, side : Global.MySide, team_pos : TeamController.TeamPosition)

const TRAIT_BUTTON : PackedScene = preload("uid://fgjqfmtn5bfl")

var beastie : Beastie = null
var side : Global.MySide = Global.MySide.LEFT
#var team_pos : TeamController.TeamPosition = TeamController.TeamPosition.FIELD_1

var all_trait_data_sorted : Array[Trait] = []

var current_search_string : String = "" :
	set(value):
		current_search_string = value
		update_grid()

@onready var search_bar: LineEdit = %SearchBar
@onready var trait_button_container: GridContainer = %TraitButtonContainer

func _ready() -> void:
	search_bar.text_changed.connect(func(new_text : String): current_search_string = new_text)
	_assign_all_data_arrays()
	update_grid()


func _assign_all_data_arrays() -> void:
	all_trait_data_sorted = Global.all_trait_data.duplicate()
	var primitive : Trait = null
	var haunted : Trait = null
	for the_trait : Trait in all_trait_data_sorted:
		if the_trait.name.to_lower() == "primitive":
			primitive = the_trait
			all_trait_data_sorted.erase(the_trait)
		elif the_trait.name.to_lower() == "haunted":
			haunted = the_trait
			all_trait_data_sorted.erase(the_trait)
	all_trait_data_sorted.sort_custom(func(t1 : Trait, t2 : Trait):
		return t1.name < t2.name
	)
	all_trait_data_sorted.push_front(haunted)
	all_trait_data_sorted.push_front(primitive)


func _get_filtered_array(search_string : String) -> Array[Trait]:
	if search_string == "":
		return all_trait_data_sorted.duplicate()

	var result : Array[Trait] = []
	for new_trait : Trait in all_trait_data_sorted:
		if new_trait and new_trait.name.to_lower().begins_with(search_string.to_lower()):
			result.append(new_trait)
	return result


func update_grid() -> void:
	if not is_node_ready():
		await ready

	for child : TraitButton in trait_button_container.get_children():
		if child.trait_selected.is_connected(self.trait_selected.emit):
			child.trait_selected.disconnect(self.trait_selected.emit)
		child.queue_free()

	var trait_array : Array[Trait] = _get_filtered_array(current_search_string)
	for new_trait : Trait in trait_array:
		var new_button : TraitButton = TRAIT_BUTTON.instantiate()
		new_button.my_trait = new_trait
		new_button.trait_selected.connect(_on_trait_button_trait_selected)
		trait_button_container.add_child(new_button)


func _on_trait_button_trait_selected(new_trait : Trait) -> void:
	if not new_trait: # Shouldn't happen
		beastie.my_trait = null
		beastie.my_trait_updated.emit(beastie.my_trait) # Have to manually emitted for some reason)
		#trait_selected.emit(null, side, team_pos)
	else:
		#beastie.my_trait = new_trait.duplicate(true)
		#beastie.my_trait_updated.emit(beastie.my_trait) # Have to manually emitted for some reason)
		#trait_selected.emit(new_trait.duplicate(true), side, team_pos)
		return


func reset() -> void:
	beastie = null
	side = Global.MySide.LEFT
	#team_pos = TeamController.TeamPosition.FIELD_1
	current_search_string = ""
	search_bar.text = ""
