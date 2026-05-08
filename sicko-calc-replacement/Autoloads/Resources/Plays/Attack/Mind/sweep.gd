@tool
extends Attack


func get_attack_pow(_attacker : Beastie, _defender : Beastie, \
					 attacker_team_controller : TeamController = null,\
					 defender_team_controller : TeamController = null) -> int: # Overwrite
	if attacker_team_controller.my_field_effects.is_empty() and defender_team_controller.my_field_effects.is_empty():
		return base_pow
	return base_pow_after_condition
