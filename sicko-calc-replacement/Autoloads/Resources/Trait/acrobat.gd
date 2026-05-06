@tool
extends Trait


func get_defense_mult(_attacker : Beastie, _defender : Beastie, _attack : Attack, \
					 _attacker_team_controller : TeamController = null,\
					 _defender_team_controller : TeamController = null) -> float: # Overwrite
	# Since it doesn't show in-game, we just don't show it too
	# and it would be hell to implement anyway
	# made this one a overwrite script just in case though
	return 1.0
