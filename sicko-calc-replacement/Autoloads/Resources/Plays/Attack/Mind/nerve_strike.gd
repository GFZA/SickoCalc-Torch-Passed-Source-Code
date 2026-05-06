@tool
extends Attack


func get_attack_pow(_attacker : Beastie, defender : Beastie, \
					 _attacker_team_controller : TeamController = null,\
					 _defender_team_controller : TeamController = null) -> int: # Overwrite
	for feelings in defender.current_feelings:
		if (defender.get_feeling_stack(Beastie.Feelings.SWEATY) > 0) or \
			(defender.get_feeling_stack(Beastie.Feelings.SHOOK) > 0) or \
			(defender.get_feeling_stack(Beastie.Feelings.ANGRY) > 0) or \
			(defender.get_feeling_stack(Beastie.Feelings.STRESSED) > 0) or \
			(defender.get_feeling_stack(Beastie.Feelings.TRIED) > 0) or \
			(defender.get_feeling_stack(Beastie.Feelings.BLOCKED) > 0) or \
			(defender.get_feeling_stack(Beastie.Feelings.NERVOUS) > 0) or \
			(defender.get_feeling_stack(Beastie.Feelings.TENDER) > 0) or \
			(defender.get_feeling_stack(Beastie.Feelings.WEEPY) > 0) or \
			(defender.get_feeling_stack(Beastie.Feelings.WIPED) > 0):
			return base_pow * 2
	return base_pow
