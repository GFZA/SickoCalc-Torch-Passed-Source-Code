@tool
class_name TeamController
extends Node2D

signal field_effects_updated(field_dict : Dictionary)

enum TeamPosition {FIELD_1, FIELD_2, BENCH_1, BENCH_2}

@export var my_field_effects : Dictionary = {} :
	set(value):
		value.sort()
		my_field_effects = value
		for field in my_field_effects.keys():
			if my_field_effects.get(field) == 0:
				my_field_effects.erase(field)
		field_effects_updated.emit(my_field_effects)

var have_cheerleader : bool = false
var have_friendship : bool = false
var weariness : int = 0


func check_for_cheerleader_buff(_attacker : Beastie) -> bool:
	return have_cheerleader


func check_for_friendship_buff(_defender : Beastie) -> bool:
	return have_friendship


func reset() -> void:
	have_cheerleader = false
	have_friendship = false


func get_field_effect_stack(field_effect : FieldEffect.Type) -> int:
	if not my_field_effects.has(field_effect):
		return 0
	return my_field_effects.get(field_effect)
