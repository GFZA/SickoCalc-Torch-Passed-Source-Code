@tool
extends Trait


func get_defense_mult(_attacker : Beastie, _defender : Beastie, _attack : Attack, \
					 _attacker_team_controller : TeamController = null,\
					 defender_team_controller : TeamController = null) -> float: # Overwrite
	if need_to_be_manually_activated:
		if manually_activated:
			return def_mult
		return 1.0

	if not defender_team_controller:
		return 1.0

	if defender_team_controller.check_if_have_wiped():
		return def_mult

	return 1.0
