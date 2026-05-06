@tool
class_name Trait
extends Resource

@export var name : String = "Primitive"
@export_multiline var description : String = "This Beastie is traitless"

@export_group("Damage multipliers")
@export_range(0.75, 2.0, 0.05) var damage_dealt_mult : float = 1.0
@export_range(1.0, 1.5, 0.1) var def_mult : float = 1.0
@export_group("Traits Special")
@export var is_starter_trait : bool = false
@export var starter_trait_type : Global.ColorType = Global.ColorType.BODY
@export var need_to_be_manually_activated : bool = false
@export var manual_condition_name : String = ""
@export var always_activate : bool = false

var manually_activated : bool = false


func get_starter_trait_boost_stack(attacker : Beastie, type : int) -> int:
	# It's no longer boost but it's easier to not change the name lol
	# The change is done to DamageCalculator btw
	if not is_starter_trait:
		return 0
	if type == int(starter_trait_type) and attacker.health < 34:
		# type will int as it's different enum but same int
		# please never do this again...
		return 1
	return 0


func get_attack_mult(_attacker : Beastie, _defender : Beastie, _attack : Attack, \
					 _attacker_team_controller : TeamController = null, \
					 _defender_team_controller : TeamController = null) -> float: # Overwrite this
	if always_activate or manually_activated:
		return damage_dealt_mult
	return 1.0


func get_defense_mult(_attacker : Beastie, _defender : Beastie, _attack : Attack, \
					 _attacker_team_controller : TeamController = null, \
					 _defender_team_controller : TeamController = null) -> float: # Overwrite this
	if always_activate or manually_activated:
		return def_mult
	return 1.0


func special_cal_formula(damage : int, _attacker : Beastie, _defender : Beastie, _attack : Attack, \
					 _attacker_team_controller : TeamController = null, \
					 _defender_team_controller : TeamController = null) -> int: # Overwrite this
	return damage
