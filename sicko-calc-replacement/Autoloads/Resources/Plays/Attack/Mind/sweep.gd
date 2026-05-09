@tool
extends Attack


func get_attack_pow(_attacker : Beastie, _defender : Beastie, \
					 attacker_team_controller : TeamController = null,\
					 defender_team_controller : TeamController = null) -> int: # Overwrite
	if need_to_be_manually_activated:
		if manually_activated:
			return base_pow_after_condition
		return base_pow

	if attacker_team_controller.my_field_effects.is_empty() and defender_team_controller.my_field_effects.is_empty():
		return base_pow
	return base_pow_after_condition
