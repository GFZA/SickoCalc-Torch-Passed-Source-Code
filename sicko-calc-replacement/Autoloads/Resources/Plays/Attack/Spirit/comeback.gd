@tool
extends Attack


func get_attack_pow(_attacker : Beastie, _defender : Beastie, \
					 attacker_team_controller : TeamController = null,\
					 defender_team_controller : TeamController = null) -> int: # Overwrite
	if defender_team_controller.current_score >= attacker_team_controller.current_score:
		return base_pow_after_condition
	return base_pow
