@tool
extends Attack

var volley_amount : int = 0

func get_attack_pow(_attacker : Beastie, _defender : Beastie, \
					 _attacker_team_controller : TeamController = null,\
					 _defender_team_controller : TeamController = null) -> int: # Overwrite
	return base_pow + ceili((base_pow * 0.5) * volley_amount)
