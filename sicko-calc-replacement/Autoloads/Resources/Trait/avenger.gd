@tool
extends Trait


func get_attack_mult(_attacker : Beastie, _defender : Beastie, _attack : Attack, \
					 attacker_team_controller : TeamController = null,\
					 _defender_team_controller : TeamController = null) -> float: # Overwrite
	if need_to_be_manually_activated:
		if manually_activated:
			return damage_dealt_mult
		return 1.0

	if not attacker_team_controller:
		return 1.0

	if attacker_team_controller.check_if_have_wiped():
		return damage_dealt_mult
	return 1.0
