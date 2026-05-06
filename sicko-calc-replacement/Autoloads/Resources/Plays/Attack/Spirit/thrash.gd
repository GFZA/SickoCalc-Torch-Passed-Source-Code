@tool
extends Attack


func get_attack_pow(attacker : Beastie, _defender : Beastie, \
					 _attacker_team_controller : TeamController = null,\
					 _defender_team_controller : TeamController = null) -> int: # Overwrite
	for feelings in attacker.current_feelings:
		if (attacker.get_feeling_stack(Beastie.Feelings.JAZZED) > 0):
			return ceili(float(base_pow) * 1.5)
	return base_pow
