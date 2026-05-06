@tool
extends Attack


func get_attack_pow(attacker : Beastie, _defender : Beastie, \
					 _attacker_team_controller : TeamController = null,\
					 _defender_team_controller : TeamController = null) -> int: # Overwrite
	for feelings in attacker.current_feelings:
		if (attacker.get_feeling_stack(Beastie.Feelings.SWEATY) > 0) or \
			(attacker.get_feeling_stack(Beastie.Feelings.NERVOUS) > 0) or \
			(attacker.get_feeling_stack(Beastie.Feelings.TENDER) > 0) or \
			(attacker.get_feeling_stack(Beastie.Feelings.WEEPY) > 0):
			return base_pow * 2
	return base_pow
