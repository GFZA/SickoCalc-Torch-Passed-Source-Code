@tool
extends Attack


func get_attack_pow(_attacker : Beastie, _defender : Beastie, \
					 attacker_team_controller : TeamController = null,\
					 _defender_team_controller : TeamController = null) -> int: # Overwrite
	if attacker_team_controller.is_serving_team:
		return ceili(int(base_pow) * 1.5)
	return base_pow
