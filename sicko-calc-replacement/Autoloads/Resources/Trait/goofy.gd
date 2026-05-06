@tool
extends Trait


func get_attack_mult(attacker : Beastie, _defender : Beastie, _attack : Attack, \
					 _attacker_team_controller : TeamController = null,\
					 _defender_team_controller : TeamController = null) -> float: # Overwrite
	var attacker_attack : Plays = attacker.my_plays[0]
	if attacker_attack and not attacker_attack.target == Attack.Target.STRAIGHT:
		return damage_dealt_mult

	return 1.0
