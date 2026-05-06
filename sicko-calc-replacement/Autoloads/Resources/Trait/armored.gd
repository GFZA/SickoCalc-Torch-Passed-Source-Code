@tool
extends Trait


func get_defense_mult(_attacker : Beastie, defender : Beastie, _attack : Attack, \
					 _attacker_team_controller : TeamController = null,\
					 _defender_team_controller : TeamController = null) -> float: # Overwrite
	if defender.health >= 100:
		return def_mult
	return 1.0
