@tool
extends Attack


func get_attack_pow(_attacker : Beastie, defender : Beastie, \
					 _attacker_team_controller : TeamController = null,\
					 _defender_team_controller : TeamController = null) -> int: # Overwrite
	return ceili(float(base_pow) * float(defender.health / 100.0))
