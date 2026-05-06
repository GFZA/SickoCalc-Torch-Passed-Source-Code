@tool
extends Attack


func get_attack_pow(_attacker : Beastie, _defender : Beastie, \
					 attacker_team_controller : TeamController = null,\
					 defender_team_controller : TeamController = null) -> int: # Overwrite
	if defender_team_controller.current_score >= attacker_team_controller.current_score:
		return ceili(int(base_pow) * 1.5)
	return base_pow
