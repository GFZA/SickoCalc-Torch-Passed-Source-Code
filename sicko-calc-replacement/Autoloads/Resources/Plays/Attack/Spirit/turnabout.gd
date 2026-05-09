@tool
extends Attack


func get_attack_pow(attacker : Beastie, _defender : Beastie, \
					 _attacker_team_controller : TeamController = null,\
					 _defender_team_controller : TeamController = null) -> int: # Overwrite
	if need_to_be_manually_activated:
		if manually_activated:
			return base_pow_after_condition
		return base_pow

	if attacker.health < 34:
		return base_pow_after_condition
	return base_pow
