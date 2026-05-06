@tool
extends Trait


func get_defense_mult(attacker : Beastie, defender : Beastie, _attack : Attack, \
					 _attacker_team_controller : TeamController = null,\
					 _defender_team_controller : TeamController = null) -> float: # Overwrite
	var defender_trait : Trait = defender.my_trait
	var is_helmet : bool = (defender_trait.name.to_lower() == "helmet")
	if not is_helmet:
		return 1.0

	var attacker_attack : Plays = attacker.my_plays[0]
	if attacker_attack and attacker_attack.target == Attack.Target.STRAIGHT:
		return def_mult

	return 1.0
