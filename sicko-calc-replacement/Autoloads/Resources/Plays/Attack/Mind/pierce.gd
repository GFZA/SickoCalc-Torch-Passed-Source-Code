@tool
extends Attack


func get_attack_pow(_attacker : Beastie, defender : Beastie, \
					 _attacker_team_controller : TeamController = null,\
					 _defender_team_controller : TeamController = null) -> int: # Overwrite
	var up_boost_count : int = 0
	for boost in defender.current_boosts:
		var boosts_to_add : int = defender.current_boosts[boost]
		if boosts_to_add < 0:
			up_boost_count += abs(boosts_to_add)
	up_boost_count = min(10, up_boost_count)
	return base_pow + ceili(float(up_boost_count) * float(base_pow) * 0.25)
