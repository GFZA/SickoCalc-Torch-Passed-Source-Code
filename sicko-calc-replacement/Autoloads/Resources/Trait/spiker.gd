@tool
extends Trait


func get_attack_mult(attacker : Beastie, _defender : Beastie, _attack : Attack, \
					 _attacker_team_controller : TeamController = null,\
					 _defender_team_controller : TeamController = null) -> float: # Overwrite
	if attacker.check_if_net():
		return damage_dealt_mult
	return 1.0
