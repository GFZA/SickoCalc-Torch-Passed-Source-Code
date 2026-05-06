@tool
extends Trait


func get_attack_mult(_attacker : Beastie, _defender : Beastie, _attack : Attack, \
					 attacker_team_controller : TeamController = null,\
					 _defender_team_controller : TeamController = null) -> float: # Overwrite
	if attacker_team_controller.is_serving_team:
		return damage_dealt_mult
	return 1.0
