@tool
extends Trait


func get_attack_mult(_attacker : Beastie, defender : Beastie, _attack : Attack, \
					 _attacker_team_controller : TeamController = null,\
					 _defender_team_controller : TeamController = null) -> float: # Overwrite
	if need_to_be_manually_activated:
		if manually_activated:
			return damage_dealt_mult
		return 1.0

	if defender.is_really_at_bench:
		return damage_dealt_mult
	return 1.0
