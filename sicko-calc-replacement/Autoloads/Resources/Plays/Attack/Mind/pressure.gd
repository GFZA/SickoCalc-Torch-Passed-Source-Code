@tool
extends Attack


func get_attack_pow(_attacker : Beastie, defender : Beastie, \
					 _attacker_team_controller : TeamController = null,\
					 _defender_team_controller : TeamController = null) -> int: # Overwrite
	if defender.is_really_at_bench:
		return base_pow * 2
	return base_pow
